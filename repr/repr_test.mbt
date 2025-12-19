///|
test "repr: with_children preserves leaves" {
  let x = Repr::int(1)
  assert_eq(Repr::children(x).length(), 0)
  match Repr::with_children(x, [Repr::int(2)]) {
    IntLit(1) => ()
    _ => fail("expected leaf to ignore new children")
  }
}

///|
test "repr: with_children falls back for Prop and AssocProp" {
  let p = Repr::prop("k", Repr::int(1))
  match Repr::with_children(p, []) {
    Prop("k", Omitted) => ()
    _ => fail("expected Prop(_, Omitted) fallback")
  }
  let ap = Repr::assoc_prop(Repr::string("k"), Repr::int(1))
  match Repr::with_children(ap, [Repr::int(0)]) {
    AssocProp(Omitted, Omitted) => ()
    _ => fail("expected AssocProp(Omitted, Omitted) fallback")
  }
}

///|
test "repr: record and assoc builders are structural" {
  let r = @repr.Repr::record({ "a": Repr::int(1), "b": Repr::bool(true) })
  match r {
    Record([Prop("a", IntLit(1)), Prop("b", BoolLit(true))]) => ()
    _ => fail("expected record to lower into Prop children")
  }
  let m = assoc([(Repr::string("a"), Repr::int(1))])
  match m {
    Assoc([AssocProp(StringLit("a"), IntLit(1))]) => ()
    _ => fail("expected assoc to lower into AssocProp children")
  }
}

///|
test "repr: traverse can hide fields" {
  let r : Repr = Repr::record({
    "user": Repr::string("alice"),
    "password": Repr::string("secret"),
  })
  let redacted = r.traverse( node =>{
    match node {
      Prop("password", _) => Repr::prop("password", Repr::omitted())
      _ => node
    }
  })
  match redacted {
    Record([Prop("user", StringLit("alice")), Prop("password", Omitted)]) => ()
    _ => fail("expected traverse to omit password")
  }
}
