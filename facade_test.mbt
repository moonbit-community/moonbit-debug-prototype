///|
fn opts_no_ansi() -> @pp.PrettyPrintOptions {
  pretty_print_options(max_depth=None, compact_threshold=100, use_ansi=false)
}

///|
test "facade: Repr constructors pretty-print as expected" {
  let opts = opts_no_ansi()
  inspect(pretty_print_repr_with(opts, int(42)), content="42")
  inspect(pretty_print_repr_with(opts, double(1.5)), content="1.5")
  inspect(pretty_print_repr_with(opts, bool(true)), content="true")
  inspect(pretty_print_repr_with(opts, char('x')), content="'x'")
  inspect(pretty_print_repr_with(opts, string("hi")), content="\"hi\"")
  inspect(
    pretty_print_repr_with(opts, array([int(1), int(2)])),
    content="[ 1, 2 ]",
  )
  inspect(
    pretty_print_repr_with(opts, record([("a", int(1)), ("b", int(2))])),
    content="{ a: 1, b: 2 }",
  )
  inspect(
    pretty_print_repr_with(opts, ctor("Ok", [string("yes")])),
    content="Ok(\"yes\")",
  )
  inspect(
    pretty_print_repr_with(
      opts,
      ctor("A", [arg("x", int(1)), arg("y", string("yes"))]),
    ),
    content="A(x=1, y=\"yes\")",
  )
  inspect(
    pretty_print_repr_with(opts, ctor("B", [arg("x", int(1)), string("s")])),
    content="B(x=1, \"s\")",
  )
  inspect(
    pretty_print_repr_with(opts, opaque_("function")),
    content="<function>",
  )
  inspect(
    pretty_print_repr_with(opts, opaque_literal("Int64", "1")),
    content="<Int64: 1>",
  )
  inspect(
    pretty_print_repr_with(opts, collection("Vec", [int(1), int(2)])),
    content="<Vec: [ 1, 2 ]>",
  )
  inspect(
    pretty_print_repr_with(opts, assoc("Map", [(string("a"), int(1))])),
    content="<Map: { \"a\": 1 }>",
  )
}

///|
test "facade: diff + pretty_print_delta wrappers round-trip" {
  let opts = opts_no_ansi()
  let x = record([("a", int(1))])
  let y = record([("a", int(2))])
  let d = diff_repr(x, y)
  inspect(pretty_print_delta_with(opts, d), content="{ a: -1 +2 }")
}

///|
test "instances: option None and numeric wrappers have repr" {
  inspect(pretty_print((None : Int?)), content="None")
  let i64 : Int64 = 1
  let u : UInt = 2
  inspect(pretty_print(i64), content="<Int64: 1>")
  inspect(pretty_print(u), content="<UInt: 2>")
}
