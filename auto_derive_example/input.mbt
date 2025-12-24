///|
#debug.derive
struct Pos {
  x : Int
  y : String
}

///|
#debug.derive
enum Lambda {
  Var(String)
  Lam(String, ty~ : String?, Lambda)
  App(Lambda, Lambda)
}

///|
#debug.derive
struct Pair(Int, Bool)

///|
#debug.derive
suberror KeyNotFound (String, SourceLoc)

///|
test {
  inspect(
    @debug.pretty_print({ x: 10, y: "20\n00" }),
    content=(
      #|{ x: 10, y: "20\n00" }
    ),
  )
  inspect(@debug.pretty_print(Pair(10, false)), content="Pair(10, false)")
  let nested = Lambda::App(Lam("x", ty=Some("Int"), Var("x")), Var("y"))
  inspect(
    @debug.pretty_print(nested),
    content=(
      #|App(Lam("x", ty=Some("Int"), Var("x")), Var("y"))
    ),
  )
  inspect(
    @debug.pretty_print(KeyNotFound(("key1", get_loc()))),
    content=(
      #|KeyNotFound(("key1", <SourceLoc: "input.mbt:40:52-40:61@dii_user/example">))
    ),
  )
}

///|
#callsite(autofill(x))
fn get_loc(x~ : SourceLoc) -> SourceLoc {
  x
}
