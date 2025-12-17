///|
/// Tree-shaped diff between two `DebugInfo` values.
pub(all) enum DebugDelta {
  Same(@repr.DebugInfo, Array[DebugDelta])
  Different(@repr.DebugInfo, @repr.DebugInfo)
  Extra1(@repr.DebugInfo)
  Extra2(@repr.DebugInfo)
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
/// Options for diffing, including float tolerance for `Double`.
pub(all) struct DiffOptions {
  max_relative_error : Double
} derive(Show, Eq)

///|
/// Default diff options used by `diff_repr`.
pub let default_diff_options : DiffOptions = {
  max_relative_error: 0.000000000001,
}

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
/// Compare two node “labels”, with float tolerance for `DoubleLit`.
fn info_approx_eq(
  max_relative_error : Double,
  x : @repr.DebugInfo,
  y : @repr.DebugInfo,
) -> Bool {
  match (x, y) {
    (@repr.DebugInfo::DoubleLit(x1), @repr.DebugInfo::DoubleLit(y1)) =>
      relative_error(x1, y1) <= max_relative_error
    (@repr.DebugInfo::IntLit(x1), @repr.DebugInfo::IntLit(y1)) => x1 == y1
    (@repr.DebugInfo::BoolLit(x1), @repr.DebugInfo::BoolLit(y1)) => x1 == y1
    (@repr.DebugInfo::CharLit(x1), @repr.DebugInfo::CharLit(y1)) => x1 == y1
    (@repr.DebugInfo::StringLit(x1), @repr.DebugInfo::StringLit(y1)) => x1 == y1
    (@repr.DebugInfo::Literal(x1), @repr.DebugInfo::Literal(y1)) => x1 == y1
    (@repr.DebugInfo::Omitted, @repr.DebugInfo::Omitted) => true
    (@repr.DebugInfo::Array(_), @repr.DebugInfo::Array(_)) => true
    (@repr.DebugInfo::Record(_), @repr.DebugInfo::Record(_)) => true
    (@repr.DebugInfo::Prop(n1, _), @repr.DebugInfo::Prop(n2, _)) => n1 == n2
    (@repr.DebugInfo::Ctor(n1, _), @repr.DebugInfo::Ctor(n2, _)) => n1 == n2
    (@repr.DebugInfo::Opaque(n1, _), @repr.DebugInfo::Opaque(n2, _)) => n1 == n2
    (@repr.DebugInfo::Assoc(n1, _), @repr.DebugInfo::Assoc(n2, _)) => n1 == n2
    (@repr.DebugInfo::AssocProp(_, _), @repr.DebugInfo::AssocProp(_, _)) => true
    _ => false
  }
}

///|
/// Labels that are treated as structural “containers” (may be collapsed in diffs).
fn info_is_unimportant(info : @repr.DebugInfo) -> Bool {
  match info {
    @repr.DebugInfo::AssocProp(_, _)
    | @repr.DebugInfo::Array(_)
    | @repr.DebugInfo::Record(_) => true
    _ => false
  }
}

///|
/// Child nodes of a `DebugInfo` node.
fn info_children(info : @repr.DebugInfo) -> Array[@repr.DebugInfo] {
  @repr.DebugInfo::children(info)
}

///|
/// A shallow copy of `info` containing only its “label” (children replaced).
fn info_shallow(info : @repr.DebugInfo) -> @repr.DebugInfo {
  @repr.DebugInfo::shallow(info)
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
/// Core `DebugInfo` diff: returns a `DebugDelta` describing differences.
fn diff_info_with(
  left : @repr.DebugInfo,
  right : @repr.DebugInfo,
  max_relative_error~ : Double,
) -> DebugDelta {
  fn differing(d : DebugDelta) -> Bool {
    match d {
      Same(_, _) => false
      _ => true
    }
  }

  fn go(
    left_node : @repr.DebugInfo,
    right_node : @repr.DebugInfo,
  ) -> DebugDelta {
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
/// Diff two `Repr` values using explicit `DiffOptions`.
pub fn diff_repr_with(
  opts : DiffOptions,
  x : @repr.Repr,
  y : @repr.Repr,
) -> ReprDelta {
  ReprDelta::from_delta(
    diff_info_with(
      @repr.Repr::info(x),
      @repr.Repr::info(y),
      max_relative_error=opts.max_relative_error,
    ),
  )
}

///|
/// Diff two `Repr` values using `default_diff_options`.
pub fn diff_repr(x : @repr.Repr, y : @repr.Repr) -> ReprDelta {
  diff_repr_with(default_diff_options, x, y)
}
