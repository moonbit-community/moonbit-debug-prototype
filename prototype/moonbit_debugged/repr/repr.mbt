///|
/// Direct structural representation for debugging/diffing/pretty-printing.
pub enum DebugInfo {
  IntLit(Int)
  DoubleLit(Double)
  BoolLit(Bool)
  CharLit(Char)
  StringLit(String)
  Array(Array[DebugInfo])
  Record(Array[DebugInfo])
  Prop(String, DebugInfo)
  Ctor(String, Array[DebugInfo])
  Opaque(String, Array[DebugInfo])
  Literal(String)
  Assoc(String, Array[DebugInfo])
  AssocProp(DebugInfo, DebugInfo)
  Omitted
} derive(Eq, Compare)

///|
/// Structural representation for debugging/diffing.
pub struct Repr(DebugInfo) derive(Eq, Compare)

///|
/// Extract the underlying structure from a `Repr`.
pub fn Repr::info(self : Repr) -> DebugInfo {
  self.0
}

///|
/// Construct a `Repr` from a raw `DebugInfo`.
pub fn Repr::from_info(info : DebugInfo) -> Repr {
  Repr(info)
}

///|
/// Smart constructors for `DebugInfo` (constructible outside the package).
pub fn DebugInfo::int_lit(x : Int) -> DebugInfo {
  IntLit(x)
}

///|
pub fn DebugInfo::double_lit(x : Double) -> DebugInfo {
  DoubleLit(x)
}

///|
pub fn DebugInfo::bool_lit(x : Bool) -> DebugInfo {
  BoolLit(x)
}

///|
pub fn DebugInfo::char_lit(x : Char) -> DebugInfo {
  CharLit(x)
}

///|
pub fn DebugInfo::string_lit(x : String) -> DebugInfo {
  StringLit(x)
}

///|
pub fn DebugInfo::array(children : Array[DebugInfo]) -> DebugInfo {
  Array(children)
}

///|
pub fn DebugInfo::record(children : Array[DebugInfo]) -> DebugInfo {
  Record(children)
}

///|
pub fn DebugInfo::prop(name : String, value : DebugInfo) -> DebugInfo {
  Prop(name, value)
}

///|
pub fn DebugInfo::ctor(name : String, args : Array[DebugInfo]) -> DebugInfo {
  Ctor(name, args)
}

///|
pub fn DebugInfo::opaque_node(
  name : String,
  children : Array[DebugInfo],
) -> DebugInfo {
  Opaque(name, children)
}

///|
pub fn DebugInfo::literal(value : String) -> DebugInfo {
  Literal(value)
}

///|
pub fn DebugInfo::assoc(
  name : String,
  children : Array[DebugInfo],
) -> DebugInfo {
  Assoc(name, children)
}

///|
pub fn DebugInfo::assoc_prop(key : DebugInfo, value : DebugInfo) -> DebugInfo {
  AssocProp(key, value)
}

///|
pub fn DebugInfo::omitted() -> DebugInfo {
  Omitted
}

///|
/// Child nodes of a `DebugInfo` node.
pub fn DebugInfo::children(self : DebugInfo) -> Array[DebugInfo] {
  match self {
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => []
    Array(xs) | Record(xs) | Ctor(_, xs) | Opaque(_, xs) | Assoc(_, xs) => xs
    Prop(_, value) => [value]
    AssocProp(key, value) => [key, value]
  }
}

///|
/// Rebuild a `DebugInfo` node with a new child list (payload is preserved).
pub fn DebugInfo::with_children(
  self : DebugInfo,
  children : Array[DebugInfo],
) -> DebugInfo {
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
    AssocProp(_, _) =>
      match children {
        [key, value] => AssocProp(key, value)
        _ => AssocProp(Omitted, Omitted)
      }
  }
}

///|
/// A shallow copy of `self` containing only its “label” (children replaced).
pub fn DebugInfo::shallow(self : DebugInfo) -> DebugInfo {
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
    AssocProp(_, _) => AssocProp(Omitted, Omitted)
  }
}

///|
/// Construct an integer `Repr`.
pub fn int(x : Int) -> Repr {
  Repr::from_info(DebugInfo::int_lit(x))
}

///|
/// Construct a double `Repr`.
pub fn double(x : Double) -> Repr {
  Repr::from_info(DebugInfo::double_lit(x))
}

///|
/// Construct a boolean `Repr`.
pub fn bool(x : Bool) -> Repr {
  Repr::from_info(DebugInfo::bool_lit(x))
}

///|
/// Construct a char `Repr`.
pub fn char(x : Char) -> Repr {
  Repr::from_info(DebugInfo::char_lit(x))
}

///|
/// Construct a string `Repr`.
pub fn string(x : String) -> Repr {
  Repr::from_info(DebugInfo::string_lit(x))
}

///|
/// Construct an array `Repr` from pre-built child `Repr`s.
pub fn array(xs : Array[Repr]) -> Repr {
  Repr::from_info(DebugInfo::array(xs.map(fn(r) { Repr::info(r) })))
}

///|
/// Convert record field pairs into property nodes.
fn make_props(fields : Array[(String, Repr)]) -> Array[DebugInfo] {
  fields.map(fn(field) {
    let (name, value) = field
    DebugInfo::prop(name, Repr::info(value))
  })
}

///|
/// Construct a record `Repr` from field name/value pairs.
pub fn record(fields : Array[(String, Repr)]) -> Repr {
  Repr::from_info(DebugInfo::record(make_props(fields)))
}

///|
/// Construct a constructor/application `Repr` with a name and argument list.
pub fn ctor(name : String, args : Array[Repr]) -> Repr {
  Repr::from_info(DebugInfo::ctor(name, args.map(fn(r) { Repr::info(r) })))
}

///|
/// Construct an opaque wrapper `Repr` with a single child.
pub fn opaque_child(name : String, child : Repr) -> Repr {
  Repr::from_info(DebugInfo::opaque_node(name, [Repr::info(child)]))
}

///|
/// Construct an opaque wrapper `Repr` with no children.
pub fn opaque_(name : String) -> Repr {
  Repr::from_info(DebugInfo::opaque_node(name, []))
}

///|
/// Construct an opaque wrapper `Repr` containing a literal leaf (already formatted).
pub fn opaque_literal(name : String, value : String) -> Repr {
  Repr::from_info(DebugInfo::opaque_node(name, [DebugInfo::literal(value)]))
}

///|
/// Convenience helper for “collection-like” reprs: `<name: [ ... ]>`.
pub fn collection(name : String, contents : Array[Repr]) -> Repr {
  opaque_child(name, array(contents))
}

///|
/// Construct an association/kv `Repr` from key/value `Repr` pairs.
pub fn assoc(name : String, contents : Array[(Repr, Repr)]) -> Repr {
  Repr::from_info(
    DebugInfo::assoc(
      name,
      contents.map(fn(pair) {
        let (k, v) = pair
        DebugInfo::assoc_prop(Repr::info(k), Repr::info(v))
      }),
    ),
  )
}
