///|
test "diff printing: arrays collapse when all children differ" {
  let x = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)])
  let y = @repr.Repr::array([@repr.Repr::int(3), @repr.Repr::int(4)])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="-[ 1, 2 ] +[ 3, 4 ]",
  )
}

///|
test "diff printing: arrays show per-element when some children same" {
  let x = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)])
  let y = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(3)])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="[ 1, -2 +3 ]",
  )
}

///|
test "diff printing: record field changes keep field name" {
  let x = @repr.Repr::record({
    "a": @repr.Repr::int(1),
    "b": @repr.Repr::int(2),
  })
  let y = @repr.Repr::record({
    "a": @repr.Repr::int(9),
    "b": @repr.Repr::int(2),
  })
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="{ a: -1 +9, b: 2 }",
  )
}

///|
test "prune: does not count RecordField as depth" {
  let r = @repr.Repr::record({
    "x": @repr.Repr::ctor("A", [@repr.Repr::ctor("B", [@repr.Repr::int(1)])]),
  })
  let opts : PrettyPrintOptions = {
    max_depth: Some(2),
    compact_threshold: 100,
    use_ansi: false,
  }
  inspect(pretty_print_repr_with(opts, r), content="{ x: A(...) }")
}

///|
test "dict entry prints `k: v`" {
  let x = @repr.Repr::dict([(@repr.Repr::string("a"), @repr.Repr::int(1))])
  let y = @repr.Repr::dict([(@repr.Repr::string("a"), @repr.Repr::int(2))])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="{ \"a\": -1 +2 }",
  )
}

///|
test "pretty print: Int16Lit" {
  let pos = @repr.Repr::int16(42)
  let neg = @repr.Repr::int16(-42)
  inspect(pretty_print_repr_with(print_opts(), pos), content="42")
  inspect(pretty_print_repr_with(print_opts(), neg), content="-42")
}

///|
test "pretty print: Int64Lit" {
  let pos = @repr.Repr::int64(1000L)
  let neg = @repr.Repr::int64(-1000L)
  inspect(pretty_print_repr_with(print_opts(), pos), content="1000L")
  inspect(pretty_print_repr_with(print_opts(), neg), content="-1000L")
}

///|
test "pretty print: UInt16Lit" {
  let x = @repr.Repr::uint16(14)
  inspect(pretty_print_repr_with(print_opts(), x), content="14")
}

///|
test "pretty print: UIntLit" {
  let x = @repr.Repr::uint(14U)
  inspect(pretty_print_repr_with(print_opts(), x), content="14U")
}

///|
test "pretty print: UInt64Lit" {
  let x = @repr.Repr::uint64(14UL)
  inspect(pretty_print_repr_with(print_opts(), x), content="14UL")
}

///|
test "pretty print: FloatLit" {
  let pos : Float = 3.14
  let neg : Float = -3.14
  inspect(
    pretty_print_repr_with(print_opts(), @repr.Repr::float(pos)),
    content="3.140000104904175",
  )
  inspect(
    pretty_print_repr_with(print_opts(), @repr.Repr::float(neg)),
    content="-3.140000104904175",
  )
}

///|
test "pretty print: BigIntLit" {
  let pos = @repr.Repr::bigint(10000000000000000000000N)
  let neg = @repr.Repr::bigint(-10000000000000000000000N)
  inspect(
    pretty_print_repr_with(print_opts(), pos),
    content="10000000000000000000000N",
  )
  inspect(
    pretty_print_repr_with(print_opts(), neg),
    content="-10000000000000000000000N",
  )
}
