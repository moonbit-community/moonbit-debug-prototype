///|
/// Tree-shaped diff between two `Repr` values.
pub(all) enum DebugDelta {
  Same(@repr.Repr, Array[DebugDelta])
  Different(@repr.Repr, @repr.Repr)
  Extra1(@repr.Repr)
  Extra2(@repr.Repr)
} derive(Eq, Compare)

///|
/// A diff of two `Repr` values.
pub struct ReprDelta(DebugDelta) derive(Eq, Compare)

///|
/// Extract the underlying delta from a `ReprDelta`.
pub fn ReprDelta::delta(self : ReprDelta) -> DebugDelta {
  self.0
}

///|
/// Construct a `ReprDelta` from a raw `DebugDelta`.
pub fn ReprDelta::from_delta(delta : DebugDelta) -> ReprDelta {
  ReprDelta(delta)
}

///|
/// Default max relative error for float comparisons.
let default_max_relative_error : Double = 0.000000000001

///|
/// Absolute value for `Double`.
fn double_abs(x : Double) -> Double {
  if x < 0.0 {
    -x
  } else {
    x
  }
}

///|
/// Maximum of two `Double` values.
fn double_max(x : Double, y : Double) -> Double {
  if x > y {
    x
  } else {
    y
  }
}

///|
/// Relative error metric used for approximate float comparisons.
fn relative_error(x : Double, y : Double) -> Double {
  if x == y {
    0.0
  } else {
    let denom = double_max(double_abs(x), double_abs(y))
    if denom == 0.0 {
      double_abs(x - y)
    } else {
      double_abs(x - y) / denom
    }
  }
}

///|
/// Compare two node "labels", with float tolerance for `DoubleLit`.
fn info_approx_eq(
  max_relative_error : Double,
  x : @repr.Repr,
  y : @repr.Repr,
) -> Bool {
  match (x, y) {
    (DoubleLit(x1), DoubleLit(y1)) =>
      relative_error(x1, y1) <= max_relative_error
    (Fixnum(x1), Fixnum(y1)) => x1 == y1
    (BoolLit(x1), BoolLit(y1)) => x1 == y1
    (CharLit(x1), CharLit(y1)) => x1 == y1
    (StringLit(x1), StringLit(y1)) => x1 == y1
    (Literal(x1), Literal(y1)) => x1 == y1
    (Omitted, Omitted) => true
    (Tuple(_), Tuple(_)) => true
    (Array(_), Array(_)) => true
    (Record(_), Record(_)) => true
    (RecordField(n1, _), RecordField(n2, _)) => n1 == n2
    (EnumLabeledArg(n1, _), EnumLabeledArg(n2, _)) => n1 == n2
    (Enum(n1, _), Enum(n2, _)) => n1 == n2
    (Opaque(n1, _), Opaque(n2, _)) => n1 == n2
    (Map(_), Map(_)) => true
    (MapEntry(_, _), MapEntry(_, _)) => true
    _ => false
  }
}

///|
/// Labels that are treated as structural "containers" (may be collapsed in diffs).
fn info_is_unimportant(info : @repr.Repr) -> Bool {
  match info {
    MapEntry(_, _) | Tuple(_) | Array(_) | Record(_) => true
    _ => false
  }
}

///|
/// Child nodes of a `Repr` node.
fn info_children(info : @repr.Repr) -> Array[@repr.Repr] {
  info.children()
}

///|
/// A shallow copy of `info` containing only its "label" (children replaced).
fn info_shallow(info : @repr.Repr) -> @repr.Repr {
  info.shallow()
}

///|
/// Returns `true` iff `p` holds for every element.
fn[T] tree_all(xs : Array[T], p : (T) -> Bool) -> Bool {
  let mut ok = true
  for x in xs {
    if !p(x) {
      ok = false
      break
    }
  }
  ok
}

///|
/// Core `Repr` diff: returns a `DebugDelta` describing differences.
fn diff_info_with(
  left : @repr.Repr,
  right : @repr.Repr,
  max_relative_error~ : Double,
) -> DebugDelta {
  fn differing(d : DebugDelta) -> Bool {
    match d {
      Same(_, _) => false
      _ => true
    }
  }

  fn go(left_node : @repr.Repr, right_node : @repr.Repr) -> DebugDelta {
    if info_approx_eq(max_relative_error, left_node, right_node) {
      let xs = info_children(left_node)
      let ys = info_children(right_node)
      let xlen = xs.length()
      let ylen = ys.length()
      let min_len = if xlen < ylen { xlen } else { ylen }
      let children : Array[DebugDelta] = for i = 0, acc = [] {
        if i < min_len {
          continue i + 1, acc + [go(xs[i], ys[i])]
        } else {
          break acc
        }
      }
      let children = if xlen < ylen {
        children + ys[min_len:ylen].to_array().map(fn(t) { Extra2(t) })
      } else if xlen > ylen {
        children + xs[min_len:xlen].to_array().map(fn(t) { Extra1(t) })
      } else {
        children
      }
      if info_is_unimportant(left_node) && tree_all(children, differing) {
        Different(left_node, right_node)
      } else {
        Same(info_shallow(left_node), children)
      }
    } else {
      Different(left_node, right_node)
    }
  }

  go(left, right)
}

///|
/// Diff two `Repr` values with optional float tolerance.
pub fn diff_repr(
  x : @repr.Repr,
  y : @repr.Repr,
  max_relative_error? : Double,
) -> ReprDelta {
  let max_relative_error = max_relative_error.unwrap_or(
    default_max_relative_error,
  )
  ReprDelta::from_delta(diff_info_with(x, y, max_relative_error~))
}
