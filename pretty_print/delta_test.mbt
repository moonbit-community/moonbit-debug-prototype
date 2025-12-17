///|
test "diff printing: arrays collapse when all children differ" {
  let x = @repr.array([@repr.int(1), @repr.int(2)])
  let y = @repr.array([@repr.int(3), @repr.int(4)])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="-[ 1, 2 ] +[ 3, 4 ]",
  )
}

///|
test "diff printing: arrays show per-element when some children same" {
  let x = @repr.array([@repr.int(1), @repr.int(2)])
  let y = @repr.array([@repr.int(1), @repr.int(3)])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="[ 1, -2 +3 ]",
  )
}

///|
test "diff printing: record field changes keep field name" {
  let x = @repr.record([("a", @repr.int(1)), ("b", @repr.int(2))])
  let y = @repr.record([("a", @repr.int(9)), ("b", @repr.int(2))])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="{ a: -1 +9, b: 2 }",
  )
}

///|
test "prune: does not count Prop as depth" {
  let r = @repr.record([
    ("x", @repr.ctor("A", [@repr.ctor("B", [@repr.int(1)])])),
  ])
  let opts : PrettyPrintOptions = {
    max_depth: Some(2),
    compact_threshold: 100,
    use_ansi: false,
  }
  inspect(pretty_print_repr_with(opts, r), content="{ x: A(...) }")
}

///|
test "assoc prop prints `k: v`" {
  let x = @repr.assoc("Map", [(@repr.string("a"), @repr.int(1))])
  let y = @repr.assoc("Map", [(@repr.string("a"), @repr.int(2))])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="<Map: { \"a\": -1 +2 }>",
  )
}
