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
/// - `Assoc` is encoded as `Assoc(name, [AssocProp(key, value), ...])`, which is
///   intended for “map-like” collections.
/// - `Opaque` is intended for “container-like” wrappers that keep a type/tag but
///   otherwise behave structurally through their children.
pub enum Repr {
  /// Integer literal leaf.
  IntLit(Int)
  /// Floating-point literal leaf.
  DoubleLit(Double)
  /// Boolean literal leaf.
  BoolLit(Bool)
  /// Character literal leaf.
  CharLit(Char)
  /// String literal leaf.
  StringLit(String)
  /// Array container node.
  Array(Array[Repr])
  /// Record container node. Conventionally contains only `Prop` children.
  Record(Array[Repr])
  /// Record field node. Conventionally appears only under `Record`.
  Prop(String, Repr)
  /// Labeled argument node. Conventionally appears only under `Ctor`.
  Arg(String, Repr)
  /// Constructor/application node: `Ctor(name, args)`.
  Ctor(String, Array[Repr])
  /// Opaque wrapper node: prints as `<name>` or `<name: ...>` and keeps children.
  Opaque(String, Array[Repr])
  /// Pre-rendered leaf string (already formatted, no quoting/escaping applied).
  Literal(String)
  /// Association/kv container with a tag name.
  Assoc(String, Array[Repr])
  /// Key/value node. Conventionally appears only under `Assoc`.
  AssocProp(Repr, Repr)
  /// Pruned subtree marker used by depth-limited pretty-printing.
  Omitted
} derive(Eq, Compare)

///|
/// Smart constructors for `Repr` (constructible outside the package).
pub fn Repr::int_lit(x : Int) -> Repr {
  IntLit(x)
}

///|
/// Construct a `DoubleLit` leaf.
pub fn Repr::double_lit(x : Double) -> Repr {
  DoubleLit(x)
}

///|
/// Construct a `BoolLit` leaf.
pub fn Repr::bool_lit(x : Bool) -> Repr {
  BoolLit(x)
}

///|
/// Construct a `CharLit` leaf.
pub fn Repr::char_lit(x : Char) -> Repr {
  CharLit(x)
}

///|
/// Construct a `StringLit` leaf.
pub fn Repr::string_lit(x : String) -> Repr {
  StringLit(x)
}

///|
/// Construct an `Array` node from pre-built child `Repr`s.
pub fn Repr::array(children : Array[Repr]) -> Repr {
  Array(children)
}

///|
/// Construct a `Record` node from pre-built child `Repr`s.
///
/// Prefer `record([("k", v), ...])` when you have name/value pairs; it ensures
/// the `Record([Prop(..), ...])` convention.
pub fn Repr::record(children : Array[Repr]) -> Repr {
  Record(children)
}

///|
/// Construct a `Prop(name, value)` record field node.
pub fn Repr::prop(name : String, value : Repr) -> Repr {
  Prop(name, value)
}

///|
/// Construct a `Arg(label, value)` labeled constructor argument node.
pub fn Repr::arg(label : String, value : Repr) -> Repr {
  Arg(label, value)
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
pub fn Repr::opaque_node(name : String, children : Array[Repr]) -> Repr {
  Opaque(name, children)
}

///|
/// Construct a `Literal(value)` leaf (already formatted).
pub fn Repr::literal(value : String) -> Repr {
  Literal(value)
}

///|
/// Construct an `Assoc(name, children)` node from pre-built child `Repr`s.
///
/// Prefer `assoc(name, [(k, v), ...])` when you have key/value pairs; it ensures
/// the `Assoc(name, [AssocProp(..), ...])` convention.
pub fn Repr::assoc(name : String, children : Array[Repr]) -> Repr {
  Assoc(name, children)
}

///|
/// Construct an `AssocProp(key, value)` key/value node.
pub fn Repr::assoc_prop(key : Repr, value : Repr) -> Repr {
  AssocProp(key, value)
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
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => []
    Array(xs) | Record(xs) | Ctor(_, xs) | Opaque(_, xs) | Assoc(_, xs) => xs
    Prop(_, value) | Arg(_, value) => [value]
    AssocProp(key, value) => [key, value]
  }
}

///|
/// Rebuild a `Repr` node with a new child list (payload is preserved).
///
/// Notes:
/// - Leaf nodes ignore `children` and return themselves.
/// - `Prop` expects exactly one child and falls back to `Prop(name, Omitted)`.
/// - `AssocProp` expects exactly two children and falls back to `AssocProp(Omitted, Omitted)`.
pub fn Repr::with_children(self : Repr, children : Array[Repr]) -> Repr {
  match self {
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => self
    Array(_) => Array(children)
    Record(_) => Record(children)
    Ctor(name, _) => Ctor(name, children)
    Opaque(name, _) => Opaque(name, children)
    Assoc(name, _) => Assoc(name, children)
    Prop(name, _) =>
      match children {
        [value] => Prop(name, value)
        _ => Prop(name, Omitted)
      }
    Arg(label, _) =>
      match children {
        [value] => Arg(label, value)
        _ => Arg(label, Omitted)
      }
    AssocProp(_, _) =>
      match children {
        [key, value] => AssocProp(key, value)
        _ => AssocProp(Omitted, Omitted)
      }
  }
}

///|
/// A shallow copy of `self` containing only its “label” (children replaced).
///
/// This is used by diff/pretty-print when the structure is preserved but
/// children are rendered separately.
pub fn Repr::shallow(self : Repr) -> Repr {
  match self {
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => self
    Array(_) => Array([])
    Record(_) => Record([])
    Ctor(name, _) => Ctor(name, [])
    Opaque(name, _) => Opaque(name, [])
    Assoc(name, _) => Assoc(name, [])
    Prop(name, _) => Prop(name, Omitted)
    Arg(label, _) => Arg(label, Omitted)
    AssocProp(_, _) => AssocProp(Omitted, Omitted)
  }
}

///|
/// Construct an integer `Repr`.
pub fn int(x : Int) -> Repr {
  Repr::int_lit(x)
}

///|
/// Construct a double `Repr`.
pub fn double(x : Double) -> Repr {
  Repr::double_lit(x)
}

///|
/// Construct a boolean `Repr`.
pub fn bool(x : Bool) -> Repr {
  Repr::bool_lit(x)
}

///|
/// Construct a char `Repr`.
pub fn char(x : Char) -> Repr {
  Repr::char_lit(x)
}

///|
/// Construct a string `Repr`.
pub fn string(x : String) -> Repr {
  Repr::string_lit(x)
}

///|
/// Construct an array `Repr` from pre-built child `Repr`s.
pub fn array(xs : Array[Repr]) -> Repr {
  Repr::array(xs)
}

///|
/// Convert record field pairs into property nodes.
fn make_props(fields : Array[(String, Repr)]) -> Array[Repr] {
  fields.map(fn(field) {
    let (name, value) = field
    Repr::prop(name, value)
  })
}

///|
/// Construct a record `Repr` from field name/value pairs.
pub fn record(fields : Array[(String, Repr)]) -> Repr {
  Repr::record(make_props(fields))
}

///|
/// Construct a constructor/application `Repr` with a name and argument list.
pub fn ctor(name : String, args : Array[Repr]) -> Repr {
  Repr::ctor(name, args)
}

///|
/// Construct a labeled argument node.
pub fn arg(label : String, value : Repr) -> Repr {
  Repr::arg(label, value)
}

///|
/// Construct an opaque wrapper `Repr` with a single child.
pub fn opaque_child(name : String, child : Repr) -> Repr {
  Repr::opaque_node(name, [child])
}

///|
/// Construct an opaque wrapper `Repr` with no children.
pub fn opaque_(name : String) -> Repr {
  Repr::opaque_node(name, [])
}

///|
/// Construct an opaque wrapper `Repr` containing a literal leaf (already formatted).
pub fn opaque_literal(name : String, value : String) -> Repr {
  Repr::opaque_node(name, [Repr::literal(value)])
}

///|
/// Convenience helper for “collection-like” reprs: `<name: [ ... ]>`.
pub fn collection(name : String, contents : Array[Repr]) -> Repr {
  opaque_child(name, array(contents))
}

///|
/// Construct an association/kv `Repr` from key/value `Repr` pairs.
pub fn assoc(name : String, contents : Array[(Repr, Repr)]) -> Repr {
  Repr::assoc(
    name,
    contents.map(fn(pair) {
      let (k, v) = pair
      Repr::assoc_prop(k, v)
    }),
  )
}
