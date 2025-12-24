///|
#debug.derive
struct Pos {
  x : Int
  y : String
  z : Double?
}

///|
/// Test pub type - should generate pub impl
#debug.derive
pub struct PubPoint {
  x : Int
  y : Int
}

///|
/// Test pub(all) type - should generate pub impl
#debug.derive
pub(all) struct PubAllPoint {
  x : Int
  y : Int
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
let loc : SourceLoc = get_loc()

///|
#callsite(autofill(x))
fn get_loc(x~ : SourceLoc) -> SourceLoc {
  x
}

///|
#debug.derive
struct Stack[T] {
  array : Array[T]
  mut current : Int
} derive(Default)

///|
pub fn[T] Stack::push(self : Self[T], x : T) -> Unit {
  self.array.push(x)
  self.current += 1
}

///|
test {
  inspect(
    @debug.pretty_print(KeyNotFound(("key1", loc))),
    content=(
      #|KeyNotFound(("key1", <SourceLoc: "input.mbt:42:23-42:32@dii_user/example">))
    ),
  )
  inspect(
    @debug.pretty_print({ x: 10, y: "20\n00", z: None }),
    content=(
      #|{ x: 10, y: "20\n00", z: None }
    ),
  )
  inspect(
    @debug.pretty_print({ x: 10, y: "20\n00", z: Some(3.14) }),
    content=(
      #|{ x: 10, y: "20\n00", z: Some(3.14) }
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
  let stack : Stack[Int] = Default::default()
  stack..push(1)..push(2)..push(3)
  inspect(
    @debug.pretty_print(stack),
    content="{ array: [ 1, 2, 3 ], current: 3 }",
  )
}
