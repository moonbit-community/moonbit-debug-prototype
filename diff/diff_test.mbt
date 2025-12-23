///|
test "diff: arrays collapse when all children differ" {
  let x = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)])
  let y = @repr.Repr::array([@repr.Repr::int(3), @repr.Repr::int(4)])
  match diff_repr(x, y).delta() {
    Different(Array(_), Array(_)) => ()
    _ => fail("expected Different(Array, Array)")
  }
}

///|
test "diff: arrays keep per-element when some children same" {
  let x = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)])
  let y = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(3)])
  match diff_repr(x, y).delta() {
    Same(Array([]), [Same(Fixnum("1"), []), _]) => ()
    _ => fail("expected Same(Array, children...)")
  }
}

///|
test "diff: extra elements are marked" {
  let x = @repr.Repr::array([@repr.Repr::int(1)])
  let y = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)])
  match diff_repr(x, y).delta() {
    Same(Array([]), [Same(Fixnum("1"), []), Extra2(Fixnum("2"))]) => ()
    _ => fail("expected Same(Array, [Same 1, Extra2 2])")
  }
}

///|
test "diff: tolerant doubles compare same" {
  let x = @repr.Repr::double(1.0)
  let y = @repr.Repr::double(1.0 + 1.0e-13)
  match diff_repr(x, y, max_relative_error=1.0e-12).delta() {
    Same(DoubleLit(_), []) => ()
    _ => fail("expected Same(DoubleLit, [])")
  }
}

///|
test "Repr is readonly but constructible via smart ctors" {
  let info = @repr.Repr::ctor("X", [(None, @repr.Repr::int(1))])
  match info {
    Enum("X", [Fixnum("1")]) => ()
    _ => fail("expected Enum(\"X\", [Fixnum(\"1\")])")
  }
  assert_eq(info.children().length(), 1)
  match info.shallow() {
    Enum("X", []) => ()
    _ => fail("expected shallow Enum(\"X\", [])")
  }
  match @repr.Repr::omitted() {
    Omitted => ()
    _ => fail("expected Omitted")
  }
}
