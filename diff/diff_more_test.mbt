///|
test "diff: extra elements on left are marked Extra1" {
  let x = @repr.array([@repr.int(1), @repr.int(2)])
  let y = @repr.array([@repr.int(1)])
  match ReprDelta::delta(diff_repr(x, y)) {
    DebugDelta::Same(
      @repr.Repr::Array([]),
      [
        DebugDelta::Same(@repr.Repr::IntLit(1), []),
        DebugDelta::Extra1(@repr.Repr::IntLit(2)),
      ]
    ) => ()
    _ => fail("expected Same(Array, [Same 1, Extra1 2])")
  }
}

///|
test "diff: BoolLit and Literal compare by value" {
  let b1 = @repr.Repr::bool_lit(true)
  let b2 = @repr.Repr::bool_lit(false)
  match ReprDelta::delta(diff_repr(b1, b2)) {
    DebugDelta::Different(@repr.Repr::BoolLit(true), @repr.Repr::BoolLit(false)) =>
      ()
    _ => fail("expected Different(BoolLit, BoolLit)")
  }
  let l1 = @repr.Repr::literal("X")
  let l2 = @repr.Repr::literal("Y")
  match ReprDelta::delta(diff_repr(l1, l2)) {
    DebugDelta::Different(@repr.Repr::Literal("X"), @repr.Repr::Literal("Y")) =>
      ()
    _ => fail("expected Different(Literal, Literal)")
  }
}

///|
test "diff: mismatched label kinds are Different" {
  let x = @repr.int(1)
  let y = @repr.string("1")
  match ReprDelta::delta(diff_repr(x, y)) {
    DebugDelta::Different(@repr.Repr::IntLit(1), @repr.Repr::StringLit("1")) =>
      ()
    _ => fail("expected Different(IntLit, StringLit)")
  }
}
