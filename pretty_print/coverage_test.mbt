///|
fn opts_no_ansi() -> PrettyPrintOptions {
  { max_depth: None, compact_threshold: 100, use_ansi: false }
}

///|
test "pretty_print: ctor without args prints without parens" {
  let opts = opts_no_ansi()
  inspect(
    pretty_print_repr_with(opts, @repr.ctor("Nothing", [])),
    content="Nothing",
  )
}

///|
test "pretty_print: opaque with children compacts to one line" {
  let opts = opts_no_ansi()
  let r = @repr.opaque_child("Int64", @repr.Repr::literal("123"))
  inspect(pretty_print_repr_with(opts, r), content="<Int64: 123>")
}

///|
test "pretty_print: empty record key is quoted" {
  let opts = opts_no_ansi()
  let r = @repr.record([("", @repr.int(0))])
  inspect(pretty_print_repr_with(opts, r), content="{ \"\": 0 }")
}

///|
test "pretty_print: long string affects layout sizing" {
  let opts : PrettyPrintOptions = {
    max_depth: None,
    compact_threshold: 2,
    use_ansi: false,
  }
  let r = @repr.array([@repr.string("0123456789abcdef")])
  inspect(pretty_print_repr_with(opts, r), content="[ \"0123456789abcdef\" ]")
}

///|
test "pretty_print: prune_delta replaces deep differences with omitted" {
  let opts : PrettyPrintOptions = {
    max_depth: Some(1),
    compact_threshold: 100,
    use_ansi: false,
  }
  let x = @repr.array([@repr.array([@repr.int(1), @repr.int(2)])])
  let y = @repr.array([@repr.array([@repr.int(1), @repr.int(3)])])
  inspect(
    pretty_print_delta_with(opts, @diff.diff_repr(x, y)),
    content="[ ... ]",
  )
}
