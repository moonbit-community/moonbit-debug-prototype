///|
enum Label {
  LInt(Int)
  LDouble(Double)
  LBool(Bool)
  LChar(Char)
  LString(String)
  LArray
  LRecord
  LProp(String)
  LApp(String)
  LOpaque(String)
  LLiteral(String)
  LAssoc(String)
  LAssocProp
  LOmitted
} derive(Eq, Compare)

///|
pub struct Repr(Tree[Label]) derive(Eq, Compare)

///|
fn un_repr(r : Repr) -> Tree[Label] {
  r.0
}

///|
pub fn int(x : Int) -> Repr {
  Repr(Node(Label::LInt(x), []))
}

///|
pub fn double(x : Double) -> Repr {
  Repr(Node(Label::LDouble(x), []))
}

///|
pub fn bool(x : Bool) -> Repr {
  Repr(Node(Label::LBool(x), []))
}

///|
pub fn char(x : Char) -> Repr {
  Repr(Node(Label::LChar(x), []))
}

///|
pub fn string(x : String) -> Repr {
  Repr(Node(Label::LString(x), []))
}

///|
pub fn array(xs : Array[Repr]) -> Repr {
  Repr(Node(Label::LArray, xs.map(fn(r) { un_repr(r) })))
}

///|
fn make_props(fields : Array[(String, Repr)]) -> Array[Tree[Label]] {
  fields.map(fn(field) {
    let (name, value) = field
    Node(Label::LProp(name), [un_repr(value)])
  })
}

///|
pub fn record(fields : Array[(String, Repr)]) -> Repr {
  Repr(Node(Label::LRecord, make_props(fields)))
}

///|
pub fn ctor(name : String, args : Array[Repr]) -> Repr {
  Repr(Node(Label::LApp(name), args.map(fn(r) { un_repr(r) })))
}

///|
pub fn opaque_child(name : String, child : Repr) -> Repr {
  Repr(Node(Label::LOpaque(name), [un_repr(child)]))
}

///|
pub fn opaque_(name : String) -> Repr {
  Repr(Node(Label::LOpaque(name), []))
}

///|
pub fn opaque_literal(name : String, value : String) -> Repr {
  Repr(Node(Label::LOpaque(name), [Node(Label::LLiteral(value), [])]))
}

///|
pub fn collection(name : String, contents : Array[Repr]) -> Repr {
  opaque_child(name, array(contents))
}

///|
pub fn assoc(name : String, contents : Array[(Repr, Repr)]) -> Repr {
  Repr(
    Node(
      Label::LAssoc(name),
      contents.map(fn(pair) {
        let (k, v) = pair
        Node(Label::LAssocProp, [un_repr(k), un_repr(v)])
      }),
    ),
  )
}
