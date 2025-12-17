///|
test "pretty_printer: empty_content prints empty" {
  inspect(print_content(no_wrap(empty_content())), content="")
}

///|
test "pretty_printer: surround_lines handles empty and singleton" {
  inspect(surround_lines("(", ")", []).join("\n"[:]), content="()")
  inspect(surround_lines("(", ")", ["x"]).join("\n"[:]), content="(x)")
}

///|
test "pretty_printer: compact_lines handles empty and multiline" {
  inspect(compact_lines([]).join("\n"[:]), content="")
  inspect(compact_lines(["a", "  b  ", "c"]).join("\n"[:]), content="a b c")
}

///|
test "pretty_printer: comma_seq_lines filters empty lines" {
  inspect(comma_seq_lines("", "", []).join("\n"[:]), content="")
}
