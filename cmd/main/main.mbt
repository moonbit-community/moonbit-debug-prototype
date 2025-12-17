///|
/// Small demo binary for `pretty_print` and `pretty_print_diff`.
pub fn demo_output() -> (String, String) {
  let items : Array[(String, Int)] = [("a", 3), ("b", 6), ("c", 13)]
  let x = Map::from_array(items[:])
  let y = Map::from_array((items + [("b", 9)])[:])
  (@lib.pretty_print(x), @lib.pretty_print_diff(x, y))
}

///|
pub fn run_demo() -> (String, String) {
  demo_output()
}

///|
fn main {
  let (a, b) = run_demo()
  println(a)
  println(b)
}
