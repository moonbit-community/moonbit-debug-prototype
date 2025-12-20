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
/// - `Record` is encoded as `Record([Prop(name, value), ...])` (not as an array
///   of `(String, Repr)` pairs) to keep generic traversal/rewrite code simple:
///   every tree edge is a `Repr`, so `children/with_children`, pruning, and diff
///   can work uniformly across node kinds.
/// - Labeled constructor arguments are encoded as `Ctor(name, [Arg(label, value), ...])`,
///   which supports mixing positional and labeled args.
/// - `Dict` is encoded as `Dict([Entry(key, value), ...])`, which is
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
  /// Record container node. Conventionally contains only `Prop` children.
  Record(Array[Repr])
  /// Record field node. Conventionally appears only under `Record`.
  Field(String, Repr)
  /// Constructor/application node: `Ctor(name, args)`.
  Ctor(String, Array[Repr])
  /// Labeled argument node. Conventionally appears only under `Ctor`.
  Labeled(String, Repr)
  /// Opaque wrapper node: prints as `<name>` or `<name: ...>` and keeps children.
  Opaque(String, Array[Repr])
  /// Pre-rendered leaf string (already formatted, no quoting/escaping applied).
  Literal(String)
  /// Association/kv container for map literals.
  Dict(Array[Repr])
  /// Key/value node. Conventionally appears only under `Dict`.
  Entry(Repr, Repr)
  /// Pruned subtree marker used by depth-limited pretty-printing.
  Omitted
} derive(Eq, Compare)

///|
pub fn Repr::unit() -> Repr {
  UnitLit
}

///|
/// Smart constructors for `Repr` (constructible outside the package).

///|
/// Construct an `Int16Lit` leaf.
pub fn Repr::int16(x : Int16) -> Repr {
  Int16Lit(x)
}

///|
/// Construct an `IntLit` leaf.
pub fn Repr::int(x : Int) -> Repr {
  IntLit(x)
}

///|
/// Construct an `Int64Lit` leaf.
pub fn Repr::int64(x : Int64) -> Repr {
  Int64Lit(x)
}

///|
/// Construct a `UInt16Lit` leaf.
pub fn Repr::uint16(x : UInt16) -> Repr {
  UInt16Lit(x)
}

///|
/// Construct a `UIntLit` leaf.
pub fn Repr::uint(x : UInt) -> Repr {
  UIntLit(x)
}

///|
/// Construct a `UInt64Lit` leaf.
pub fn Repr::uint64(x : UInt64) -> Repr {
  UInt64Lit(x)
}

///|
/// Construct a `DoubleLit` leaf.
pub fn Repr::double(x : Double) -> Repr {
  DoubleLit(x)
}

///|
/// Construct a `FloatLit` leaf.
pub fn Repr::float(x : Float) -> Repr {
  FloatLit(x)
}

///|
/// Construct a `BigIntLit` leaf.
pub fn Repr::bigint(x : BigInt) -> Repr {
  BigIntLit(x)
}

///|
/// Construct a `BoolLit` leaf.
pub fn Repr::bool(x : Bool) -> Repr {
  BoolLit(x)
}

///|
/// Construct a `CharLit` leaf.
pub fn Repr::char(x : Char) -> Repr {
  CharLit(x)
}

///|
/// Construct a `StringLit` leaf.
pub fn Repr::string(x : String) -> Repr {
  StringLit(x)
}

///|
/// Construct a `Tuple` node from pre-built child `Repr`s.
pub fn Repr::tuple(children : Array[Repr]) -> Repr {
  Tuple(children)
}

///|
/// Construct an `Array` node from pre-built child `Repr`s.
pub fn Repr::array(children : Array[Repr]) -> Repr {
  Array(children)
}

///|
/// Construct a `Record` node from pre-built child `Repr`s.
pub fn Repr::record(fields : Map[String, Repr]) -> Repr {
  Record(fields.to_array().map(fn(p) { Field(p.0, p.1) }))
}

///|
/// Construct a `Prop(name, value)` record field node.
pub fn Repr::field(name : String, value : Repr) -> Repr {
  Field(name, value)
}

///|
/// Construct a `Arg(label, value)` labeled constructor argument node.
pub fn Repr::labeled(label : String, value : Repr) -> Repr {
  Labeled(label, value)
}

///|
/// Construct a `Ctor(name, args)` node.
pub fn Repr::ctor(name : String, args : Array[Repr]) -> Repr {
  Ctor(name, args)
}

///|
/// Construct an `Opaque(name, children)` node.
///
/// This is useful for values where you want to keep a tag/type name but still
/// show a structural summary through children (e.g. `<Map: {...}>`).
pub fn Repr::opaque_(name : String, children : Array[Repr]) -> Repr {
  Opaque(name, children)
}

///|
/// Construct a `Literal(value)` leaf (already formatted).
pub fn Repr::literal(value : String) -> Repr {
  Literal(value)
}

///|
/// Construct a `Dict` node from key/value `Repr` pairs (for map literals).
pub fn Repr::dict(contents : Array[(Repr, Repr)]) -> Repr {
  Dict(
    contents.map(fn(pair) {
      let (k, v) = pair
      Repr::entry(k, v)
    }),
  )
}

///|
/// Construct an `Entry(key, value)` key/value node for map literals.
pub fn Repr::entry(key : Repr, value : Repr) -> Repr {
  Entry(key, value)
}

///|
/// Construct an `Omitted` marker node.
pub fn Repr::omitted() -> Repr {
  Omitted
}

///|
/// Child nodes of a `Repr` node.
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
    | Ctor(_, xs)
    | Opaque(_, xs)
    | Dict(xs) => xs
    Field(_, value) | Labeled(_, value) => [value]
    Entry(key, value) => [key, value]
  }
}

///|
/// Rebuild a `Repr` node with a new child list (payload is preserved).
///
/// Notes:
/// - Leaf nodes ignore `children` and return themselves.
/// - `Prop` expects exactly one child and falls back to `Prop(name, Omitted)`.
/// - `Entry` expects exactly two children and falls back to `Entry(Omitted, Omitted)`.
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
    Ctor(name, _) => Ctor(name, children)
    Opaque(name, _) => Opaque(name, children)
    Dict(_) => Dict(children)
    Field(name, _) =>
      match children {
        [value] => Field(name, value)
        _ => Field(name, Omitted)
      }
    Labeled(label, _) =>
      match children {
        [value] => Labeled(label, value)
        _ => Labeled(label, Omitted)
      }
    Entry(_, _) =>
      match children {
        [key, value] => Entry(key, value)
        _ => Entry(Omitted, Omitted)
      }
  }
}

///|
/// Traverse a `Repr` tree and rewrite each node with `f`.
///
/// `f` runs after children are traversed (post-order), so it sees rewritten
/// children and can hide fields by rewriting `Prop`/`Arg` nodes.
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
    Ctor(name, _) => Ctor(name, [])
    Opaque(name, _) => Opaque(name, [])
    Dict(_) => Dict([])
    Field(name, _) => Field(name, Omitted)
    Labeled(label, _) => Labeled(label, Omitted)
    Entry(_, _) => Entry(Omitted, Omitted)
  }
}
