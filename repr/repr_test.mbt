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
test "repr: with_children falls back for fixed-arity nodes" {
  let p = Repr::field("k", Repr::int(1))
  match p.with_children([]) {
    RecordField("k", Omitted) => ()
    _ => fail("expected RecordField(_, Omitted) fallback")
  }
  let l = Repr::labeled("k", Repr::int(1))
  match l.with_children([]) {
    EnumLabeledArg("k", Omitted) => ()
    _ => fail("expected EnumLabeledArg(_, Omitted) fallback")
  }
  let e = match Repr::dict([(Repr::string("k"), Repr::int(1))]) {
    Map([entry]) => entry
    _ => fail("expected dict to contain one MapEntry")
  }
  match e.with_children([Repr::int(0)]) {
    MapEntry(Omitted, Omitted) => ()
    _ => fail("expected MapEntry(Omitted, Omitted) fallback")
  }
}

///|
test "repr: record and dict builders are structural" {
  let r = @repr.Repr::record({ "a": Repr::int(1), "b": Repr::bool(true) })
  match r {
    Record([RecordField("a", IntLit(1)), RecordField("b", BoolLit(true))]) => ()
    _ => fail("expected record to lower into RecordField children")
  }
  let m = Repr::dict([(Repr::string("a"), Repr::int(1))])
  match m {
    Map([MapEntry(StringLit("a"), IntLit(1))]) => ()
    _ => fail("expected dict to lower into MapEntry children")
  }
}

///|
test "repr: with_children round-trips with children" {
  let entry = match Repr::dict([(Repr::string("k"), Repr::int(5))]) {
    Map([entry]) => entry
    _ => fail("expected dict to contain one MapEntry")
  }
  let samples = [
    Repr::unit(),
    Repr::int(1),
    Repr::tuple([Repr::int(1), Repr::int(2)]),
    Repr::array([Repr::string("x")]),
    Repr::record({ "a": Repr::int(1) }),
    Repr::ctor("C", [Repr::int(2)]),
    Repr::opaque_("T", [Repr::string("x")]),
    Repr::dict([(Repr::string("k"), Repr::bool(true))]),
    Repr::field("f", Repr::int(3)),
    Repr::labeled("l", Repr::int(4)),
    entry,
    Repr::omitted(),
  ]
  for r in samples {
    if r.with_children(r.children()) != r {
      fail("expected with_children(children) round-trip")
    }
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
      RecordField("password", _) => Repr::field("password", Repr::omitted())
      _ => node
    }
  })
  match redacted {
    Record(
      [
        RecordField("user", StringLit("alice")),
        RecordField("password", Omitted),
      ]
    ) => ()
    _ => fail("expected traverse to omit password")
  }
}
