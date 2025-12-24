# `moonbit-community/debug/repr`

This package defines `Repr` : a small, structural, tree-shaped representation
used by `moonbit-community/debug` for:

* pretty-printing (`moonbit-community/debug/pretty_print`)
* diffing (`moonbit-community/debug/diff`)
* the `Debug` trait (`moonbit-community/debug`)

`Repr` is exported as a readonly enum ( `pub enum Repr` ), so it can be
pattern-matched outside the package but not directly constructed. Use the smart
constructors ( `Repr::...` ) or the convenience functions ( `int` , `record` , ...).

## Records

A record node is represented structurally as:

* `Record([RecordField(name, value), ...])`

### Why `Record(Array[Repr])` + `RecordField` ?

You might wonder why we don’t model records more “directly” as something like
`Record(Array[(String, Repr)])` . The choice here is deliberate:

* **Uniform traversal/rewrite**: every tree edge is a `Repr`. Generic utilities
  like `Repr::children` , `Repr::with_children` , pruning, and the diff algorithm
  can treat records exactly like arrays/ctors/opaque nodes without special-cases
  for `(String, Repr)` pairs.
* **Field names live in the tree**: a field is a real node (`RecordField(name, ...)`), 
  so pretty-printing and diffing can use the same “label + children” pipeline
  everywhere.
* **Keeps the public API small**: an alternative representation would either
  complicate the `children/with_children` contract (because record “children”
  aren’t `Repr` values) or require additional parallel APIs just for records.

If you want “map-like” semantics (key/value pairs as first-class children), use
`Map([MapEntry(key, value), ...])` , which is what the `Debug` instance for
`Map` uses.

So for a value conceptually shaped like:

```text
record { x : Int; y : String }
```

the corresponding `Repr` is:

```text
Record([
  RecordField("x", Fixnum(...)),
  RecordField("y", StringLit(...)),
])
```

### Example (runnable)

```mbt check
///|
test {
  let r : Repr = @repr.Repr::record({
    "x": Repr::int(1),
    "y": Repr::string("hi"),
  })
  match r {
    Record([RecordField("x", Fixnum("1")), RecordField("y", StringLit("hi"))]) =>
      ()
    _ => fail("unexpected Repr shape for record {x: Int; y: String}")
  }
}
```

## Tuples (and unit)

Tuples are represented as:

- `Tuple([a, b, ...])`

Unit is the empty tuple:

- `Tuple([])` (also constructible with `unit()`)

### Example (runnable)

```mbt check
///|
test {
  let t : Repr = Repr::tuple([Repr::int(1), Repr::string("x")])
  match t {
    Tuple([Fixnum("1"), StringLit("x")]) => ()
    _ => fail("unexpected Repr shape for tuple (Int, String)")
  }
}
```

## Labeled constructor arguments

MoonBit enum variants (and tuple-struct constructors) can have labeled arguments.
To preserve those labels in a `Repr` , use `Repr::ctor` with optional labels:

* `Repr::ctor("A", [(Some("x"), ...), (Some("y"), ...)])`
  prints as `A(x=..., y=...)`

* you can freely mix positional and labeled args:
 `Repr::ctor("B", [(Some("x"), ...), (None, ...)])`

prints as `B(x=..., ...)`

### Example (runnable)

```mbt check
///|
test {
  let r : Repr = Repr::ctor("A", [
    (Some("x"), Repr::int(1)),
    (Some("y"), Repr::string("hi")),
  ])
  match r {
    Enum(
      "A",
      [EnumLabeledArg("x", Fixnum("1")), EnumLabeledArg("y", StringLit("hi"))]
    ) => ()
    _ => fail("unexpected Repr shape for labeled ctor A(x=Int, y=String)")
  }
}
```
