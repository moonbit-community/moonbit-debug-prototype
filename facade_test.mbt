///|
test "facade: Repr constructors pretty-print as expected" {
  inspect(
    pretty_print_repr(Repr::int(42), compact_threshold=100, use_ansi=false),
    content="42",
  )
  inspect(
    pretty_print_repr(Repr::double(1.5), compact_threshold=100, use_ansi=false),
    content="1.5",
  )
  inspect(
    pretty_print_repr(Repr::bool(true), compact_threshold=100, use_ansi=false),
    content="true",
  )
  inspect(
    pretty_print_repr(Repr::char('x'), compact_threshold=100, use_ansi=false),
    content="'x'",
  )
  inspect(
    pretty_print_repr(Repr::string("hi"), compact_threshold=100, use_ansi=false),
    content="\"hi\"",
  )
  inspect(
    pretty_print_repr(Repr::tuple([]), compact_threshold=100, use_ansi=false),
    content="()",
  )
  inspect(
    pretty_print_repr(
      Repr::tuple([Repr::int(1), Repr::string("x")]),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="(1, \"x\")",
  )
  inspect(
    pretty_print_repr(
      Repr::array([Repr::int(1), Repr::int(2)]),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="[ 1, 2 ]",
  )
  inspect(
    pretty_print_repr(
      Repr::record({ "a": Repr::int(1), "b": Repr::int(2) }),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="{ a: 1, b: 2 }",
  )
  inspect(
    pretty_print_repr(
      Repr::ctor("Ok", [(None, Repr::string("yes"))]),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="Ok(\"yes\")",
  )
  inspect(
    pretty_print_repr(
      Repr::ctor("A", [
        (Some("x"), Repr::int(1)),
        (Some("y"), Repr::string("yes")),
      ]),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="A(x=1, y=\"yes\")",
  )
  inspect(
    pretty_print_repr(
      Repr::ctor("B", [(Some("x"), Repr::int(1)), (None, Repr::string("s"))]),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="B(x=1, \"s\")",
  )
  inspect(
    pretty_print_repr(
      Repr::opaque_("function", []),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="<function>",
  )
  inspect(
    pretty_print_repr(
      Repr::opaque_("Int64", [Repr::literal("1")]),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="<Int64: 1>",
  )
  inspect(
    pretty_print_repr(
      Repr::opaque_("Vec", [Repr::array([Repr::int(1), Repr::int(2)])]),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="<Vec: [ 1, 2 ]>",
  )
  inspect(
    pretty_print_repr(
      Repr::dict([(Repr::string("a"), Repr::int(1))]),
      compact_threshold=100,
      use_ansi=false,
    ),
    content="{ \"a\": 1 }",
  )
}

///|
test "facade: diff + pretty_print_delta wrappers round-trip" {
  let x = Repr::record({ "a": Repr::int(1) })
  let y = Repr::record({ "a": Repr::int(2) })
  let d = diff_repr(x, y)
  inspect(
    pretty_print_delta(d, compact_threshold=100, use_ansi=false),
    content="{ a: -1 +2 }",
  )
}

///|
test "instances: option None and numeric wrappers have repr" {
  inspect(pretty_print((None : Int?)), content="None")
  let i64 : Int64 = 1
  let u : UInt = 2
  inspect(pretty_print(i64), content="<Int64: 1>")
  inspect(pretty_print(u), content="<UInt: 2>")
}
