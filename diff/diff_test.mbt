///|
test "diff: arrays collapse when all children differ" {
  let x = @repr.array([@repr.int(1), @repr.int(2)])
  let y = @repr.array([@repr.int(3), @repr.int(4)])
  match ReprDelta::delta(diff_repr(x, y)) {
    Different(Array(_), Array(_)) => ()
    _ => fail("expected Different(Array, Array)")
  }
}

///|
test "diff: arrays keep per-element when some children same" {
  let x = @repr.array([@repr.int(1), @repr.int(2)])
  let y = @repr.array([@repr.int(1), @repr.int(3)])
  match ReprDelta::delta(diff_repr(x, y)) {
    Same(Array([]), [Same(IntLit(1), []), _]) => ()
    _ => fail("expected Same(Array, children...)")
  }
}

///|
test "diff: extra elements are marked" {
  let x = @repr.array([@repr.int(1)])
  let y = @repr.array([@repr.int(1), @repr.int(2)])
  match ReprDelta::delta(diff_repr(x, y)) {
    Same(Array([]), [Same(IntLit(1), []), Extra2(IntLit(2))]) => ()
    _ => fail("expected Same(Array, [Same 1, Extra2 2])")
  }
}

///|
test "diff: tolerant doubles compare same" {
  let opts : DiffOptions = { max_relative_error: 1.0e-12 }
  let x = @repr.double(1.0)
  let y = @repr.double(1.0 + 1.0e-13)
  match ReprDelta::delta(diff_repr_with(opts, x, y)) {
    Same(DoubleLit(_), []) => ()
    _ => fail("expected Same(DoubleLit, [])")
  }
}

///|
test "Repr is readonly but constructible via smart ctors" {
  let info = @repr.Repr::ctor("X", [@repr.Repr::int_lit(1)])
  match info {
    Ctor("X", [IntLit(1)]) => ()
    _ => fail("expected Ctor(\"X\", [IntLit(1)])")
  }
  assert_eq(@repr.Repr::children(info).length(), 1)
  match @repr.Repr::shallow(info) {
    Ctor("X", []) => ()
    _ => fail("expected shallow Ctor(\"X\", [])")
  }
  match @repr.Repr::omitted() {
    Omitted => ()
    _ => fail("expected Omitted")
  }
}
