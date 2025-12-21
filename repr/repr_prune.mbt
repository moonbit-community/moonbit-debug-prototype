///|
/// Whether visiting this node should decrement the remaining depth budget.
pub fn Repr::info_adds_depth(info : Repr) -> Bool {
  match info {
    RecordField(_, _) | EnumLabeledArg(_, _) | MapEntry(_, _) => false
    _ => true
  }
}

///|
/// Prune a `Repr` value to a given depth (replacing pruned subtrees).
pub fn Repr::prune_info(info : Repr, replacement~ : Repr, depth~ : Int) -> Repr {
  fn go(d : Int, node : Repr) -> Repr {
    let children = node.children()
    if d <= 0 {
      if children.is_empty() {
        node
      } else if !node.info_adds_depth() {
        node.with_children(children.map(fn(child) { go(d, child) }))
      } else {
        replacement
      }
    } else if children.is_empty() {
      node
    } else {
      let next_depth = if node.info_adds_depth() { d - 1 } else { d }
      node.with_children(children.map(fn(child) { go(next_depth, child) }))
    }
  }

  go(Int::max(1, depth), info)
}
