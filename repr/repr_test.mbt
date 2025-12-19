///|
test "repr: with_children preserves leaves" {
  let x = Repr::int(1)
  assert_eq(x.children().length(), 0)
  match x.with_children([Repr::int(2)]) {
    IntLit(1) => ()
    _ => fail("expected leaf to ignore new children")
  }
}

///|
test "repr: with_children falls back for Prop and AssocProp" {
  let p = Repr::field("k", Repr::int(1))
  match p.with_children([]) {
    Field("k", Omitted) => ()
    _ => fail("expected Prop(_, Omitted) fallback")
  }
  let ap = Repr::entry(Repr::string("k"), Repr::int(1))
  match ap.with_children([Repr::int(0)]) {
    Entry(Omitted, Omitted) => ()
    _ => fail("expected AssocProp(Omitted, Omitted) fallback")
  }
}

///|
test "repr: record and dict builders are structural" {
  let r = @repr.Repr::record({ "a": Repr::int(1), "b": Repr::bool(true) })
  match r {
    Record([Field("a", IntLit(1)), Field("b", BoolLit(true))]) => ()
    _ => fail("expected record to lower into Field children")
  }
  let m = Repr::dict([(Repr::string("a"), Repr::int(1))])
  match m {
    Dict([Entry(StringLit("a"), IntLit(1))]) => ()
    _ => fail("expected dict to lower into Entry children")
  }
}

///|
test "repr: traverse can hide fields" {
  let r : Repr = Repr::record({
    "user": Repr::string("alice"),
    "password": Repr::string("secret"),
  })
  let redacted = r.traverse(fn(node) {
    match node {
      Field("password", _) => Repr::field("password", Repr::omitted())
      _ => node
    }
  })
  match redacted {
    Record([Field("user", StringLit("alice")), Field("password", Omitted)]) =>
      ()
    _ => fail("expected traverse to omit password")
  }
}
