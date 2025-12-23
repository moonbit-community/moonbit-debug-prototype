///|
test "debug_trait: diff uses explicit options" {
  let x : Double = 1.0
  let y : Double = 1.0 + 1.0e-13
  match diff(x, y, max_relative_error=0.0).delta() {
    Different(_, _) => ()
    _ => fail("expected strict diff to be Different")
  }
  match diff(x, y, max_relative_error=1.0e-12).delta() {
    Same(DoubleLit(_), []) => ()
    _ => fail("expected tolerant diff to be Same")
  }
}

///|
test "debug_trait: pretty_print_diff uses default options" {
  inspect(pretty_print_diff(1, 1), content="1")
  inspect(
    pretty_print_diff(1, 2),
    content="\u001b[31m-1\u001b[0m \u001b[32m+2\u001b[0m",
  )
}
