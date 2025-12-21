# Deriving `Repr` in MoonBit (design + examples)

`Repr` is a small, tree-shaped representation intended for:

- pretty-printing (surface-syntax-ish output)
- structural diffing
- building custom debug views for your own types

This repository currently exposes `Repr` via the `Debug` trait:

```mbt
pub(open) trait Debug {
  debug(Self) -> @repr.Repr
}
```

If `Repr` is incorporated into the MoonBit standard library, you can expose the
same idea as a `Repr`/`ToRepr` trait and make `derive(Repr)` generate the
implementations described below.

The key idea: map every value into a `@repr.Repr` tree using a small set of
constructors, chosen to match MoonBit surface syntax as closely as possible.

---

## 1) Literals and primitives

Use literal leaves for the basic scalar types:

- `Int` → `@repr.int(n)`
- `Double` → `@repr.double(x)`
- `Bool` → `@repr.bool(b)`
- `Char` → `@repr.char(c)`
- `String` → `@repr.string(s)`

Example:

```mbt
pub impl @dbg.Debug for String with debug(self) {
  @dbg.string(self)
}
```

For “non-`Int` integers” (e.g. `Int64`, `UInt`, `Byte`, `UInt64`), a good default
is to keep the type name and render the value as text:

```mbt
pub impl @dbg.Debug for Int64 with debug(self) {
  @dbg.opaque_literal("Int64", repr(self))
}
```

This prints as `<Int64: 1>`.

---

## 2) Unit and tuples

Tuples are represented structurally (not as a stringly-typed ctor):

- `()` (unit) → `@repr.unit()` (which is `Tuple([])`)
- `(a, b, ...)` → `@repr.tuple([repr(a), repr(b), ...])`

Example:

```mbt
pub impl @dbg.Debug for Unit with debug(_) {
  @dbg.unit()
}

pub impl[A : @dbg.Debug, B : @dbg.Debug] @dbg.Debug for (A, B) with debug(self) {
  let (a, b) = self
  @dbg.tuple([@dbg.debug(a), @dbg.debug(b)])
}
```

---

## 3) Arrays and array-like types

For `Array[T]`, use the `Array` node:

- `Array[T]` → `@repr.array(xs.map(debug))`

Example:

```mbt
pub impl[T : @dbg.Debug] @dbg.Debug for Array[T] with debug(self) {
  @dbg.array(self.map(fn(x) { @dbg.debug(x) }))
}
```

For other “sequence-like” types where you still want a bracket view, use the
same `Array` node (optionally wrapped to keep a type tag):

```mbt
pub impl[T : @dbg.Debug] @dbg.Debug for @yourpkg.FixedArray[T] with debug(self) {
  @dbg.collection("FixedArray", self.to_array().map(fn(x) { @dbg.debug(x) }))
}
```

This prints as `<FixedArray: [ ... ]>`.

---

## 3.1) Generic collections (`Collection[A]`)

For “collection-like” generic types, prefer a sequence-style representation
instead of a record-of-fields view.

For example, given a generic wrapper:

```mbt
struct Collection[A] {
  items : Array[A]
}
```

you can implement `Debug` generically by requiring the element type to also
implement `Debug`, then mapping `debug` over the elements:

```mbt
pub impl[A : @dbg.Debug] @dbg.Debug for Collection[A] with debug(self) {
  @dbg.collection(
    "Collection",
    self.items.map(fn(x) { @dbg.debug(x) }),
  )
}
```

This prints as `<Collection: [ ... ]>` and preserves per-element diffs (because
the inner value is an `Array` node).

---

## 4) Record/struct types (named fields)

Use a `Record` node containing `RecordField(name, value)` children:

- `struct { x : Int; y : String }` → `@repr.record([("x", ...), ("y", ...)])`

Example:

```mbt
struct Person {
  name : String
  age : Int
}

pub impl @dbg.Debug for Person with debug(self) {
  @dbg.record([("name", @dbg.debug(self.name)), ("age", @dbg.debug(self.age))])
}
```

This prints as `{ name: "Alice", age: 42 }`.

Notes:

- Field names are printed unquoted when they are valid identifiers; otherwise
  they are printed as quoted string literals (useful for map/object-like data).
- Record `RecordField` nodes do not count towards the “depth budget” when pretty
  printing, so you still see the field names when values are pruned.

---

## 5) Enums (positional arguments)

Represent enum variants as constructor applications:

- `A(1, "x")` → `@repr.ctor("A", [@repr.int(1), @repr.string("x")])`
- `D(1)` → `@repr.ctor("D", [@repr.int(1)])`
- `None` (no args) → `@repr.ctor("None", [])`

Example:

```mbt
enum Expr {
  Lit(Int)
  Add(Expr, Expr)
}

pub impl @dbg.Debug for Expr with debug(self) {
  match self {
    Lit(n) => @dbg.ctor("Lit", [@dbg.debug(n)])
    Add(a, b) => @dbg.ctor("Add", [@dbg.debug(a), @dbg.debug(b)])
  }
}
```

This prints as `Add(Lit(1), Lit(2))`.

---

## 6) Enums with labeled arguments (and mixed args)

MoonBit supports labeled enum arguments like:

```mbt
enum LabeledValue {
  A(x~ : Int, y~ : String)
  B(x~ : Int, String)
  D(Int)
}
```

Use `ctor_args` with `CtorArg::Labeled` to preserve the labels:

- `A(x=1, y="s")` →
  `@repr.ctor_args("A", [@repr.CtorArg::Labeled("x", @repr.int(1)), @repr.CtorArg::Labeled("y", @repr.string("s"))])`
- `B(x=1, "s")` →
  `@repr.ctor_args("B", [@repr.CtorArg::Labeled("x", @repr.int(1)), @repr.CtorArg::Pos(@repr.string("s"))])`

Example implementation:

```mbt
pub impl @dbg.Debug for LabeledValue with debug(self) {
  match self {
    A(x~, y~) =>
      @dbg.ctor_args(
        "A",
        [@dbg.CtorArg::Labeled("x", @dbg.debug(x)), @dbg.CtorArg::Labeled("y", @dbg.debug(y))],
      )
    B(x~, s) =>
      @dbg.ctor_args(
        "B",
        [@dbg.CtorArg::Labeled("x", @dbg.debug(x)), @dbg.CtorArg::Pos(@dbg.debug(s))],
      )
    D(n) => @dbg.ctor("D", [@dbg.debug(n)])
  }
}
```

---

## 7) Map-like / association containers

Use `Map([MapEntry(key, value), ...])` for key/value collections:

- `Map[K, V]` → `@repr.dict([(k1, v1), ...].map(debug))`

Example:

```mbt
pub impl[K : @dbg.Debug, V : @dbg.Debug] @dbg.Debug for Map[K, V] with debug(self) {
  @dbg.dict(
    self.to_array().map(fn(kv) {
      let (k, v) = kv
      (@dbg.debug(k), @dbg.debug(v))
    }),
  )
}
```

This prints as `{ "a": 1, "b": 2 }`.

---

## 8) Opaque / custom types

When a type is:

- not structurally interesting,
- too large/noisy to show structurally,
- or would require a domain-specific view,

use `Opaque`:

- just a tag: `opaque_("function")` → `<function>`
- tag + structural child: `opaque_child("Vec", array([...]))` → `<Vec: [ ... ]>`
- tag + literal: `opaque_literal("Date", "2019-02-01")` → `<Date: 2019-02-01>`

Prefer structural children when you want good diffs; prefer `opaque_literal` when
you only need a compact summary.

---

## 9) Practical `derive(Repr)` mapping (summary)

If you implement `derive(Repr)` in the compiler, a good default mapping is:

- primitives → corresponding literal leaves
- tuple / unit → `Tuple([...])`
- array-like sequences → `Array([...])` (optionally wrapped via `Opaque`/`collection`)
- generic collection wrappers (e.g. `Collection[A]`) → add `A : Repr` constraint and map over elements
- record structs → `Record([RecordField(field, value), ...])`
- tuple structs/newtypes → `Enum(TypeName, [...])`
- enum variants:
  - positional args → `Enum(VariantName, [...])`
  - labeled args → `Enum(VariantName, [EnumLabeledArg(label, value), ...])` (mixed allowed)
- maps/dicts → `Map([MapEntry(key, value), ...])`

For cyclic graphs (possible with `mut`/`Ref`), a derived implementation should
also track visited nodes to avoid infinite recursion (policy choice: print
`<cycle>` / `<ref #n>` / or fall back to `opaque_literal`).
