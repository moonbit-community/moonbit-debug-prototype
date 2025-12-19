///|
test "diff: extra elements on left are marked Extra1" {
  let x = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)])
  let y = @repr.Repr::array([@repr.Repr::int(1)])
  match diff_repr(x, y).delta() {
    Same(Array([]), [Same(IntLit(1), []), Extra1(IntLit(2))]) => ()
    _ => fail("expected Same(Array, [Same 1, Extra1 2])")
  }
}

///|
test "diff: BoolLit and Literal compare by value" {
  let b1 = @repr.Repr::bool(true)
  let b2 = @repr.Repr::bool(false)
  match diff_repr(b1, b2).delta() {
    Different(BoolLit(true), BoolLit(false)) => ()
    _ => fail("expected Different(BoolLit, BoolLit)")
  }
  let l1 = @repr.Repr::literal("X")
  let l2 = @repr.Repr::literal("Y")
  match diff_repr(l1, l2).delta() {
    Different(Literal("X"), Literal("Y")) => ()
    _ => fail("expected Different(Literal, Literal)")
  }
}

///|
test "diff: mismatched label kinds are Different" {
  let x = @repr.Repr::int(1)
  let y = @repr.Repr::string("1")
  match diff_repr(x, y).delta() {
    Different(IntLit(1), StringLit("1")) => ()
    _ => fail("expected Different(IntLit, StringLit)")
  }
}
