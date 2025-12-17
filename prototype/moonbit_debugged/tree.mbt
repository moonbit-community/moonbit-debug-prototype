///|
enum Tree[T] {
  Node(T, Array[Tree[T]])
} derive(Eq, Compare)

///|
fn[A, B] tree_map(tree : Tree[A], f : (A) -> B) -> Tree[B] {
  match tree {
    Node(label, children) =>
      Node(f(label), children.map(fn(child) { tree_map(child, f) }))
  }
}

///|
fn[A, B] fold_tree(tree : Tree[A], f : (A, Array[B]) -> B) -> B {
  match tree {
    Node(label, children) =>
      f(label, children.map(fn(child) { fold_tree(child, f) }))
  }
}

///|
fn[A] prune_tree(
  tree : Tree[A],
  replacement~ : A,
  counts~ : (A) -> Bool,
  depth~ : Int,
) -> Tree[A] {
  fn int_max(x : Int, y : Int) -> Int {
    if x > y {
      x
    } else {
      y
    }
  }

  fn go(d : Int, t : Tree[A]) -> Tree[A] {
    match t {
      // reached leaf anyway
      Node(_, []) if d <= 0 => t
      Node(_, _) if d <= 0 => Node(replacement, [])
      Node(label, children) => {
        let next_depth = if counts(label) { d - 1 } else { d }
        Node(label, children.map(fn(child) { go(next_depth, child) }))
      }
    }
  }

  go(int_max(1, depth), tree)
}
