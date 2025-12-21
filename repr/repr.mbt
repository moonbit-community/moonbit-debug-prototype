// | type     | description                                       | example                    |
// | -------- | ------------------------------------------------- | -------------------------- |
// | `Int16`  | 16-bit signed integer                             | `(42 : Int16)`             |
// | `Int`    | 32-bit signed integer                             | `42`                       |
// | `Int64`  | 64-bit signed integer                             | `1000L`                    |
// | `UInt16` | 16-bit unsigned integer                           | `(14 : UInt16)`            |
// | `UInt`   | 32-bit unsigned integer                           | `14U`                      |
// | `UInt64` | 64-bit unsigned integer                           | `14UL`                     |
// | `Double` | 64-bit floating point, defined by IEEE754         | `3.14`                     |
// | `Float`  | 32-bit floating point                             | `(3.14 : Float)`           |
// | `BigInt` | represents numeric values larger than other types | `10000000000000000000000N` |

///|
/// Direct structural representation for debugging/diffing/pretty-printing.
///
/// `pub` makes it readonly outside this package: it can be pattern-matched but
/// not directly constructed. Use the smart constructors below.
///
/// Design notes:
/// - `Record` is encoded as `Record([RecordField(name, value), ...])` (not as an array
///   of `(String, Repr)` pairs) to keep generic traversal/rewrite code simple:
///   every tree edge is a `Repr`, so `children/with_children`, pruning, and diff
///   can work uniformly across node kinds.
/// - Labeled enum arguments are encoded as
///   `Enum(name, [EnumLabeledArg(label, value), ...])`,
///   which supports mixing positional and labeled args.
/// - `Map` is encoded as `Map([MapEntry(key, value), ...])`, which is
///   intended for “map-like” collections (MoonBit map literals like `{ k: v }`).
/// - `Opaque` is intended for “container-like” wrappers that keep a type/tag but
///   otherwise behave structurally through their children.
pub enum Repr {
  UnitLit
  /// 16-bit signed integer literal leaf.
  Int16Lit(Int16)
  /// 32-bit signed integer literal leaf.
  IntLit(Int)
  /// 64-bit signed integer literal leaf.
  Int64Lit(Int64)
  /// 16-bit unsigned integer literal leaf.
  UInt16Lit(UInt16)
  /// 32-bit unsigned integer literal leaf.
  UIntLit(UInt)
  /// 64-bit unsigned integer literal leaf.
  UInt64Lit(UInt64)
  /// 64-bit floating-point literal leaf.
  DoubleLit(Double)
  /// 32-bit floating-point literal leaf.
  FloatLit(Float)
  /// Big integer literal leaf.
  BigIntLit(BigInt)
  /// Boolean literal leaf.
  BoolLit(Bool)
  /// Character literal leaf.
  CharLit(Char)
  /// String literal leaf.
  StringLit(String)
  /// Tuple node. Children are the tuple elements (`Tuple([])` is unit).
  Tuple(Array[Repr])
  /// Array container node.
  Array(Array[Repr])
  /// Record container node. Conventionally contains only `RecordField` children.
  Record(Array[Repr])
  /// Enum constructor/application node: `Enum(name, args)`.
  Enum(String, Array[Repr])
  /// Association/kv container for map literals.
  Map(Array[Repr])
  /// Record field node. Conventionally appears only under `Record`.
  RecordField(String, Repr)
  /// Labeled argument node. Conventionally appears only under `Enum`.
  EnumLabeledArg(String, Repr)
  /// Opaque wrapper node: prints as `<name>` or `<name: ...>` and keeps children.
  Opaque(String, Array[Repr])
  /// Pre-rendered leaf string (already formatted, no quoting/escaping applied).
  Literal(String)
  /// Key/value node. Conventionally appears only under `Map`.
  MapEntry(Repr, Repr)
  /// Pruned subtree marker used by depth-limited pretty-printing.
  Omitted
} derive(Eq, Compare)

///|
/// Constructor arguments for `Repr::ctor_args`.
pub(all) enum CtorArg {
  /// Positional constructor argument.
  Pos(Repr)
  /// Labeled constructor argument.
  Labeled(String, Repr)
} derive(Eq, Compare)

///|
pub fn Repr::unit() -> Repr {
  UnitLit
}

///|
/// Construct a positional constructor argument.
pub fn CtorArg::pos(value : Repr) -> CtorArg {
  Pos(value)
}

///|
/// Construct a labeled constructor argument.
pub fn CtorArg::labeled(label : String, value : Repr) -> CtorArg {
  Labeled(label, value)
}

///|
/// Construct an `Enum(name, args)` node for enum/constructor applications.
///
/// This assumes positional arguments only. Use `Repr::ctor_args` to mix labeled
/// and positional arguments.
pub fn Repr::ctor(name : String, args : Array[Repr]) -> Repr {
  Enum(name, args)
}

///|
/// Construct an `Enum(name, args)` node from labeled/positional arguments.
pub fn Repr::ctor_args(name : String, args : Array[CtorArg]) -> Repr {
  Enum(
    name,
    args.map(fn(arg) {
      match arg {
        Pos(value) => value
        Labeled(label, value) => Repr::labeled(label, value)
      }
    }),
  )
}

///|
/// Child nodes of a `Repr` node.
///
/// Design notes:
/// - Leaves return `[]`; container nodes return their stored children.
/// - `RecordField`/`EnumLabeledArg` have one child; `MapEntry` has two.
/// - `children` and `with_children` form a partial lens for tree rewrites:
///   `self.with_children(self.children()) == self`.
pub fn Repr::children(self : Repr) -> Array[Repr] {
  match self {
    UnitLit
    | Int16Lit(_)
    | IntLit(_)
    | Int64Lit(_)
    | UInt16Lit(_)
    | UIntLit(_)
    | UInt64Lit(_)
    | DoubleLit(_)
    | FloatLit(_)
    | BigIntLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => []
    Tuple(xs)
    | Array(xs)
    | Record(xs)
    | Enum(_, xs)
    | Opaque(_, xs)
    | Map(xs) => xs
    RecordField(_, value) | EnumLabeledArg(_, value) => [value]
    MapEntry(key, value) => [key, value]
  }
}

///|
/// Rebuild a `Repr` node with a new child list (payload is preserved).
///
/// Notes:
/// - Leaf nodes ignore `children` and return themselves.
/// - `RecordField`/`EnumLabeledArg` expect exactly one child and fall back to
///   `RecordField(name, Omitted)`/`EnumLabeledArg(label, Omitted)`.
/// - `MapEntry` expects exactly two children and falls back to `MapEntry(Omitted, Omitted)`.
/// - This is intentionally not a total inverse of `children`: invalid arity is
///   clamped to keep the tree well-formed for generic traversal.
pub fn Repr::with_children(self : Repr, children : Array[Repr]) -> Repr {
  match self {
    UnitLit
    | Int16Lit(_)
    | IntLit(_)
    | Int64Lit(_)
    | UInt16Lit(_)
    | UIntLit(_)
    | UInt64Lit(_)
    | DoubleLit(_)
    | FloatLit(_)
    | BigIntLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => self
    Tuple(_) => Tuple(children)
    Array(_) => Array(children)
    Record(_) => Record(children)
    Enum(name, _) => Enum(name, children)
    Opaque(name, _) => Opaque(name, children)
    Map(_) => Map(children)
    RecordField(name, _) =>
      match children {
        [value] => RecordField(name, value)
        _ => RecordField(name, Omitted)
      }
    EnumLabeledArg(label, _) =>
      match children {
        [value] => EnumLabeledArg(label, value)
        _ => EnumLabeledArg(label, Omitted)
      }
    MapEntry(_, _) =>
      match children {
        [key, value] => MapEntry(key, value)
        _ => MapEntry(Omitted, Omitted)
      }
  }
}

///|
/// Traverse a `Repr` tree and rewrite each node with `f`.
///
/// `f` runs after children are traversed (post-order), so it sees rewritten
/// children and can hide fields by rewriting `RecordField`/`EnumLabeledArg` nodes.
pub fn Repr::traverse(self : Repr, f : (Repr) -> Repr) -> Repr {
  fn go(node : Repr) -> Repr {
    let children = node.children()
    let next_children = children.map(fn(child) { go(child) })
    f(node.with_children(next_children))
  }

  go(self)
}

///|
/// A shallow copy of `self` containing only its “label” (children replaced).
///
/// This is used by diff/pretty-print when the structure is preserved but
/// children are rendered separately.
pub fn Repr::shallow(self : Repr) -> Repr {
  match self {
    UnitLit
    | Int16Lit(_)
    | IntLit(_)
    | Int64Lit(_)
    | UInt16Lit(_)
    | UIntLit(_)
    | UInt64Lit(_)
    | DoubleLit(_)
    | FloatLit(_)
    | BigIntLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => self
    Tuple(_) => Tuple([])
    Array(_) => Array([])
    Record(_) => Record([])
    Enum(name, _) => Enum(name, [])
    Opaque(name, _) => Opaque(name, [])
    Map(_) => Map([])
    RecordField(name, _) => RecordField(name, Omitted)
    EnumLabeledArg(label, _) => EnumLabeledArg(label, Omitted)
    MapEntry(_, _) => MapEntry(Omitted, Omitted)
  }
}
