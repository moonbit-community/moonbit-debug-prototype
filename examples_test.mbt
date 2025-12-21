///|
struct Person {
  name : String
  age : Int
} derive(Show, Eq)

///|
pub impl Debug for Person with debug(self) {
  @repr.Repr::record({ "name": debug(self.name), "age": debug(self.age) })
}

///|
enum Expr {
  Lit(Int)
  Var(String)
  Add(left~ : Expr, right~ : Expr)
} derive(Show, Eq)

///|
pub impl Debug for Expr with debug(self) {
  match self {
    Lit(n) => Repr::ctor("Lit", [debug(n)])
    Var(s) => Repr::ctor("Var", [debug(s)])
    Add(left~, right~) =>
      Repr::ctor_args("Add", [
        CtorArg::Labeled("left", debug(left)),
        CtorArg::Labeled("right", debug(right)),
      ])
  }
}

///|
test "custom struct pretty_print" {
  let p : Person = { name: "Alice", age: 42 }
  inspect(pretty_print(p), content="{ name: \"Alice\", age: 42 }")
}

///|
test "custom enum pretty_print and prune" {
  let expr : Expr = Add(left=Add(left=Lit(1), right=Var("x")), right=Lit(2))
  inspect(
    pretty_print(expr),
    content="Add(left=Add(left=Lit(1), right=Var(\"x\")), right=Lit(2))",
  )
  let opts = pretty_print_options(
    max_depth=Some(2),
    compact_threshold=100,
    use_ansi=false,
  )
  inspect(
    pretty_print_with(opts, expr),
    content="Add(left=Add(left=..., right=...), right=Lit(2))",
  )
}

///|
test "custom enum diff (no ansi)" {
  let x : Expr = Add(left=Lit(1), right=Var("x"))
  let y : Expr = Add(left=Lit(1), right=Var("y"))
  let opts = pretty_print_options(
    max_depth=Some(6),
    compact_threshold=100,
    use_ansi=false,
  )
  inspect(
    pretty_print_diff_with(opts, x, y),
    content="Add(left=Lit(1), right=Var(-\"x\" +\"y\"))",
  )
}
