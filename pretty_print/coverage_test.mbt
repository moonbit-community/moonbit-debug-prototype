///|
test "pretty_print: ctor without args prints without parens" {
  inspect(
    pretty_print_repr(
      @repr.Repr::ctor("Nothing", []),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="Nothing",
  )
}

///|
test "pretty_print: opaque with children compacts to one line" {
  let r = @repr.Repr::opaque_("Int64", [@repr.Repr::literal("123")])
  inspect(
    pretty_print_repr(r, compact_threshold=100, use_ansi=false),
    content="<Int64: 123>",
  )
}

///|
test "pretty_print: empty record key is quoted" {
  let r = @repr.Repr::record({ "": @repr.Repr::int(0) })
  inspect(
    pretty_print_repr(r, compact_threshold=100, use_ansi=false),
    content="{ \"\": 0 }",
  )
}

///|
test "pretty_print: long string affects layout sizing" {
  let r = @repr.Repr::array([@repr.Repr::string("0123456789abcdef")])
  inspect(
    pretty_print_repr(r, compact_threshold=2, use_ansi=false),
    content="[ \"0123456789abcdef\" ]",
  )
}

///|
test "pretty_print: prune_delta replaces deep differences with omitted" {
  let x = @repr.Repr::array([
    @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)]),
  ])
  let y = @repr.Repr::array([
    @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(3)]),
  ])
  inspect(
    pretty_print_delta(
      @diff.diff_repr(x, y),
      max_depth=1,
      compact_threshold=100,
      use_ansi=false,
    ),
    content="[ ... ]",
  )
}
