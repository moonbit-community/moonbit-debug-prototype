///|
test "repr: with_children preserves leaves" {
  let x = Repr::int_lit(1)
  assert_eq(Repr::children(x).length(), 0)
  match Repr::with_children(x, [Repr::int_lit(2)]) {
    Repr::IntLit(1) => ()
    _ => fail("expected leaf to ignore new children")
  }
}

///|
test "repr: with_children falls back for Prop and AssocProp" {
  let p = Repr::prop("k", Repr::int_lit(1))
  match Repr::with_children(p, []) {
    Repr::Prop("k", Repr::Omitted) => ()
    _ => fail("expected Prop(_, Omitted) fallback")
  }
  let ap = Repr::assoc_prop(Repr::string_lit("k"), Repr::int_lit(1))
  match Repr::with_children(ap, [Repr::int_lit(0)]) {
    Repr::AssocProp(Repr::Omitted, Repr::Omitted) => ()
    _ => fail("expected AssocProp(Omitted, Omitted) fallback")
  }
}

///|
test "repr: record and assoc builders are structural" {
  let r = record([("a", int(1)), ("b", bool(true))])
  match r {
    Repr::Record(
      [Repr::Prop("a", Repr::IntLit(1)), Repr::Prop("b", Repr::BoolLit(true))]
    ) => ()
    _ => fail("expected record to lower into Prop children")
  }
  let m = assoc("Map", [(string("a"), int(1))])
  match m {
    Repr::Assoc("Map", [Repr::AssocProp(Repr::StringLit("a"), Repr::IntLit(1))]) =>
      ()
    _ => fail("expected assoc to lower into AssocProp children")
  }
}
