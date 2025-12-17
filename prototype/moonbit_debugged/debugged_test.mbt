///|
test "pretty_print repr for map" {
  let items : Array[(String, Int)] = [("a", 3), ("b", 6), ("c", 13)]
  let x : Map[String, Int] = Map::from_array(items[:])
  inspect(pretty_print(x), content="<Map: { \"a\": 3, \"b\": 6, \"c\": 13 }>")
}

///|
test "pretty_print delta for map (no ansi)" {
  let items : Array[(String, Int)] = [("a", 3), ("b", 6), ("c", 13)]
  let x : Map[String, Int] = Map::from_array(items[:])
  let y : Map[String, Int] = Map::from_array((items + [("b", 9)])[:])
  let opts : PrettyPrintOptions = {
    max_depth: Some(6),
    compact_threshold: 40,
    use_ansi: false,
  }
  inspect(
    pretty_print_delta_with(opts, diff(x, y)),
    content="<Map: { \"a\": 3, \"b\": -6 +9, \"c\": 13 }>",
  )
}

///|
test "opaque types have a repr" {
  let r = opaque_("function")
  inspect(pretty_print_repr(r), content="<function>")
  inspect(pretty_print_delta(diff_repr(r, r)), content="<function>")
}
