///|
test "docs: pretty_print for option and tuple" {
  inspect(pretty_print(Some(1)), content="Some(1)")
  inspect(pretty_print((1, "x")), content="(1, \"x\")")
}
