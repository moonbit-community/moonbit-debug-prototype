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
    Lit(n) => Repr::ctor("Lit", [(None, debug(n))])
    Var(s) => Repr::ctor("Var", [(None, debug(s))])
    Add(left~, right~) =>
      Repr::ctor("Add", [
        (Some("left"), debug(left)),
        (Some("right"), debug(right)),
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
  inspect(
    pretty_print(expr, max_depth=2, compact_threshold=100, use_ansi=false),
    content="Add(left=Add(left=..., right=...), right=Lit(2))",
  )
}

///|
test "custom enum diff (no ansi)" {
  let x : Expr = Add(left=Lit(1), right=Var("x"))
  let y : Expr = Add(left=Lit(1), right=Var("y"))
  inspect(
    pretty_print_diff(x, y, max_depth=6, compact_threshold=100, use_ansi=false),
    content="Add(left=Lit(1), right=Var(-\"x\" +\"y\"))",
  )
}
