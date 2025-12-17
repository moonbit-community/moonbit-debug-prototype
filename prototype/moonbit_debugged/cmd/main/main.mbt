///|
fn main {
  let items : Array[(String, Int)] = [("a", 3), ("b", 6), ("c", 13)]
  let x = Map::from_array(items[:])
  let y = Map::from_array((items + [("b", 9)])[:])
  println(@lib.pretty_print(x))
  println(@lib.pretty_print_diff(x, y))
}
