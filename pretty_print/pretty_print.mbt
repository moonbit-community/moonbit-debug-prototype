///|
/// Options controlling pruning/formatting and ANSI markers.
pub(all) struct PrettyPrintOptions {
  max_depth : Int?
  compact_threshold : Int
  use_ansi : Bool
} derive(Show, Eq)

///|
/// Default pretty-print options used by `pretty_print_repr` / `pretty_print_delta`.
pub let default_pretty_print_options : PrettyPrintOptions = {
  max_depth: Some(4),
  compact_threshold: 8,
  use_ansi: true,
}

///|
/// Whether visiting this node should decrement the remaining depth budget.
fn info_adds_depth(info : @repr.Repr) -> Bool {
  match info {
    Field(_, _) | Labeled(_, _) | Entry(_, _) => false
    _ => true
  }
}

///|
/// Child nodes of a `Repr` node.
fn info_children(info : @repr.Repr) -> Array[@repr.Repr] {
  info.children()
}

///|
/// Rebuild a `Repr` node with a new child list (payload is preserved).
fn info_with_children(
  info : @repr.Repr,
  children : Array[@repr.Repr],
) -> @repr.Repr {
  info.with_children(children)
}

///|
/// A shallow copy of `info` containing only its “label” (children replaced).
fn info_shallow(info : @repr.Repr) -> @repr.Repr {
  info.shallow()
}

///|
/// Prune a `Repr` value to a given depth (replacing pruned subtrees).
fn prune_info(
  info : @repr.Repr,
  replacement~ : @repr.Repr,
  counts~ : (@repr.Repr) -> Bool,
  depth~ : Int,
) -> @repr.Repr {
  fn int_max(x : Int, y : Int) -> Int {
    if x > y {
      x
    } else {
      y
    }
  }

  fn go(d : Int, node : @repr.Repr) -> @repr.Repr {
    let children = info_children(node)
    if d <= 0 {
      if children.is_empty() {
        node
      } else if !counts(node) {
        info_with_children(node, children.map(fn(child) { go(d, child) }))
      } else {
        replacement
      }
    } else if children.is_empty() {
      node
    } else {
      let next_depth = if counts(node) { d - 1 } else { d }
      info_with_children(
        node,
        children.map(fn(child) { go(next_depth, child) }),
      )
    }
  }

  go(int_max(1, depth), info)
}

///|
/// Prune a `Repr` using `opts.max_depth` (replacing with `Omitted`).
fn prune_repr_info(opts : PrettyPrintOptions, info : @repr.Repr) -> @repr.Repr {
  match opts.max_depth {
    None => info
    Some(depth) =>
      prune_info(
        info,
        replacement=@repr.Repr::omitted(),
        counts=info_adds_depth,
        depth~,
      )
  }
}

///|
/// Prune a `DebugDelta` using `opts.max_depth` (replacing with `Same(Omitted, [])`).
fn prune_delta(
  opts : PrettyPrintOptions,
  delta : @diff.DebugDelta,
) -> @diff.DebugDelta {
  fn int_max(x : Int, y : Int) -> Int {
    if x > y {
      x
    } else {
      y
    }
  }

  fn go(d : Int, node : @diff.DebugDelta) -> @diff.DebugDelta {
    match node {
      Same(label, children) =>
        if d <= 0 {
          if children.is_empty() {
            node
          } else if !info_adds_depth(label) {
            Same(label, children.map(fn(child) { go(d, child) }))
          } else {
            Same(@repr.Repr::omitted(), [])
          }
        } else {
          let next_depth = if info_adds_depth(label) { d - 1 } else { d }
          Same(label, children.map(fn(child) { go(next_depth, child) }))
        }
      Different(left, right) =>
        if d <= 0 {
          Same(@repr.Repr::omitted(), [])
        } else {
          Different(
            prune_info(
              left,
              replacement=@repr.Repr::omitted(),
              counts=info_adds_depth,
              depth=d,
            ),
            prune_info(
              right,
              replacement=@repr.Repr::omitted(),
              counts=info_adds_depth,
              depth=d,
            ),
          )
        }
      Extra1(x) =>
        if d <= 0 {
          Same(@repr.Repr::omitted(), [])
        } else {
          Extra1(
            prune_info(
              x,
              replacement=@repr.Repr::omitted(),
              counts=info_adds_depth,
              depth=d,
            ),
          )
        }
      Extra2(x) =>
        if d <= 0 {
          Same(@repr.Repr::omitted(), [])
        } else {
          Extra2(
            prune_info(
              x,
              replacement=@repr.Repr::omitted(),
              counts=info_adds_depth,
              depth=d,
            ),
          )
        }
    }
  }

  match opts.max_depth {
    None => delta
    Some(depth) => go(int_max(1, depth), delta)
  }
}

///|
/// Heuristic “size” of a node for compact-vs-multiline decisions.
fn info_size(info : @repr.Repr) -> Int {
  match info {
    UnitLit => 1
    Int16Lit(_) => 1
    IntLit(_) => 1
    Int64Lit(_) => 1
    UInt16Lit(_) => 1
    UIntLit(_) => 1
    UInt64Lit(_) => 1
    DoubleLit(_) => 1
    FloatLit(_) => 1
    BigIntLit(_) => 1
    BoolLit(_) => 1
    CharLit(_) => 1
    StringLit(s) => if s.length() <= 15 { 1 } else { 2 }
    Tuple(_) => 1
    Array(_) => 1
    Record(_) => 2
    Field(name, _) => if name.length() <= 15 { 0 } else { 1 }
    Labeled(name, _) => if name.length() <= 15 { 0 } else { 1 }
    Ctor(name, _) => if name.length() <= 15 { 1 } else { 2 }
    Opaque(name, _) => if name.length() <= 15 { 1 } else { 2 }
    Literal(s) => if s.length() <= 15 { 1 } else { 2 }
    Dict(_) => 2
    Entry(_, _) => 0
    Omitted => 0
  }
}

///|
/// Heuristic “size” of a delta for compact-vs-multiline decisions.
fn delta_root_size(delta : @diff.DebugDelta) -> Int {
  match delta {
    Same(label, _) => info_size(label)
    _ => 0
  }
}

///|
/// Total “size” of a node (root + children).
fn measure(root_size : Int, children : Array[Content]) -> Int {
  let mut total = root_size
  for c in children {
    total += c.size
  }
  total
}

///|
/// Render compactly when the measured size stays under `threshold`.
fn with_resizing(
  root_size : Int,
  threshold : Int,
  f : (Array[Content]) -> Content,
  children : Array[Content],
) -> Content {
  if measure(root_size, children) <= threshold {
    compact(f(children))
  } else {
    f(children)
  }
}

///|
/// Returns `true` when a record field name can be printed without quotes.
fn is_unquoted_key(key : String) -> Bool {
  fn is_lower_alpha_ascii(ch : Char) -> Bool {
    ch >= 'a' && ch <= 'z'
  }

  fn is_upper_alpha_ascii(ch : Char) -> Bool {
    ch >= 'A' && ch <= 'Z'
  }

  fn is_numeric_ascii(ch : Char) -> Bool {
    ch >= '0' && ch <= '9'
  }

  fn is_unquoted_key_head(ch : Char) -> Bool {
    ch == '_' || is_lower_alpha_ascii(ch)
  }

  fn is_unquoted_key_tail(ch : Char) -> Bool {
    ch == '_' ||
    is_lower_alpha_ascii(ch) ||
    is_upper_alpha_ascii(ch) ||
    is_numeric_ascii(ch)
  }

  if key.is_empty() {
    false
  } else {
    let chars = key.to_array()
    let head = chars[0]
    if !is_unquoted_key_head(head) {
      false
    } else {
      for i = 1, ok = true
          i < chars.length()
          i = i + 1, ok = ok && is_unquoted_key_tail(chars[i]) {

      } else {
        ok
      }
    }
  }
}

///|
/// Escape a string as a literal (used for quoted keys and `String` values).
fn quote_string_literal(s : String) -> String {
  s.escape()
}

///|
/// Pretty-print a record field name (quoted when needed).
fn pretty_print_label(name : String) -> String {
  if is_unquoted_key(name) {
    name
  } else {
    quote_string_literal(name)
  }
}

///|
/// Render a single `Repr` node (label + rendered children) into `Content`.
fn pretty_print_repr_go(
  label : @repr.Repr,
  children : Array[Content],
) -> Content {
  match label {
    UnitLit => comma_seq("(", ")", [])
    Int16Lit(x) => leaf(x, needs_parens=x < 0)
    IntLit(x) => leaf(x, needs_parens=x < 0)
    Int64Lit(x) => leaf_with_suffix(x, "L", needs_parens=x < 0L)
    UInt16Lit(x) => leaf(x)
    UIntLit(x) => leaf_with_suffix(x, "U")
    UInt64Lit(x) => leaf_with_suffix(x, "UL")
    DoubleLit(x) => {
      let needs_parens = 1.0 / x < 0.0
      leaf(x, needs_parens~)
    }
    FloatLit(x) => {
      let needs_parens : Bool = (1.0 : Float) / x < (0.0 : Float)
      leaf(x, needs_parens~)
    }
    BigIntLit(x) => leaf_with_suffix(x, "N", needs_parens=x < 0N)
    BoolLit(x) => leaf(x)
    CharLit(x) => leaf(x)
    StringLit(x) => no_parens(verbatim(quote_string_literal(x)))
    Tuple(_) => comma_seq("(", ")", children.map(no_wrap))
    Ctor(name, _) =>
      match children {
        [] => no_parens(verbatim(name))
        _ =>
          if name == "Tuple" {
            comma_seq("(", ")", children.map(no_wrap))
          } else {
            comma_seq(name + "(", ")", children.map(no_wrap))
          }
      }
    Array(_) => comma_seq("[ ", " ]", children.map(no_wrap))
    Record(_) => comma_seq("{ ", " }", children.map(no_wrap))
    Opaque(name, _) =>
      if children.is_empty() {
        no_parens(surround("<", ">", verbatim(name)))
      } else {
        let body = verbatim(name + ":") +
          indent("  ", no_wrap(comma_seq("", "", children.map(no_wrap))))
        no_parens(surround("<", ">", body))
      }
    Literal(str) => no_parens(verbatim(str))
    Dict(_) => comma_seq("{ ", " }", children.map(no_wrap))
    Entry(_, _) =>
      match children {
        [key, val] => no_parens(surround("", ":", no_wrap(key)) + no_wrap(val))
        _ => empty_content()
      }
    Labeled(name, _) =>
      match children {
        [val] =>
          match val.lines {
            [] => empty_content()
            [first] =>
              no_parens({ size: 1 + val.size, lines: [name + "=" + first] })
            [first, ..] => {
              let n = val.lines.length()
              let rest = if n <= 1 { [] } else { val.lines[1:n].to_array() }
              no_parens({
                size: 1 + val.size,
                lines: [name + "=" + first] + rest,
              })
            }
          }
        _ => empty_content()
      }
    Field(name, _) =>
      match children {
        [val] =>
          no_parens(
            verbatim(pretty_print_label(name) + ":") +
            indent("  ", no_wrap(val)),
          )
        _ => empty_content()
      }
    Omitted => parens(verbatim("..."))
  }
}

///|
/// ANSI escape for green.
fn ansi_green() -> String {
  "\u001b[32m"
}

///|
/// ANSI escape for red.
fn ansi_red() -> String {
  "\u001b[31m"
}

///|
/// ANSI escape reset.
fn ansi_reset() -> String {
  "\u001b[0m"
}

///|
/// Mark added content with `+` (and optionally ANSI color).
fn mark_added(opts : PrettyPrintOptions, x : ContentParens) -> ContentParens {
  if opts.use_ansi {
    surround(ansi_green() + "+", ansi_reset(), x)
  } else {
    surround("+", "", x)
  }
}

///|
/// Mark removed content with `-` (and optionally ANSI color).
fn mark_removed(opts : PrettyPrintOptions, x : ContentParens) -> ContentParens {
  if opts.use_ansi {
    surround(ansi_red() + "-", ansi_reset(), x)
  } else {
    surround("-", "", x)
  }
}

///|
/// Render a `Repr` as `Content` with resizing decisions.
fn render_repr(opts : PrettyPrintOptions, info : @repr.Repr) -> Content {
  let label = info_shallow(info)
  let children = info_children(info).map(fn(child) { render_repr(opts, child) })
  with_resizing(
    info_size(label),
    opts.compact_threshold,
    fn(children) { pretty_print_repr_go(label, children) },
    children,
  )
}

///|
/// Render a `DebugDelta` as `Content` with resizing decisions.
fn render_delta(opts : PrettyPrintOptions, delta : @diff.DebugDelta) -> Content {
  match delta {
    Same(label, children_delta) => {
      let children = children_delta.map(fn(child) { render_delta(opts, child) })
      with_resizing(
        delta_root_size(delta),
        opts.compact_threshold,
        fn(children) { pretty_print_repr_go(label, children) },
        children,
      )
    }
    Different(left, right) => {
      let children : Array[Content] = [
        render_repr(opts, left),
        render_repr(opts, right),
      ]
      with_resizing(
        0,
        opts.compact_threshold,
        fn(children) {
          match children {
            [left, right] =>
              no_parens(
                mark_removed(opts, no_wrap(left)) +
                mark_added(opts, no_wrap(right)),
              )
            _ => empty_content()
          }
        },
        children,
      )
    }
    Extra1(x) => {
      let children : Array[Content] = [render_repr(opts, x)]
      with_resizing(
        0,
        opts.compact_threshold,
        fn(children) {
          match children {
            [x] => no_parens(mark_removed(opts, no_wrap(x)))
            _ => empty_content()
          }
        },
        children,
      )
    }
    Extra2(x) => {
      let children : Array[Content] = [render_repr(opts, x)]
      with_resizing(
        0,
        opts.compact_threshold,
        fn(children) {
          match children {
            [x] => no_parens(mark_added(opts, no_wrap(x)))
            _ => empty_content()
          }
        },
        children,
      )
    }
  }
}

///|
/// Pretty-print a `Repr` using explicit `PrettyPrintOptions`.
pub fn pretty_print_repr_with(
  opts : PrettyPrintOptions,
  r : @repr.Repr,
) -> String {
  let info = prune_repr_info(opts, r)
  print_content(no_wrap(render_repr(opts, info)))
}

///|
/// Pretty-print a `Repr` using `default_pretty_print_options`.
pub fn pretty_print_repr(r : @repr.Repr) -> String {
  pretty_print_repr_with(default_pretty_print_options, r)
}

///|
/// Pretty-print a `ReprDelta` using explicit `PrettyPrintOptions`.
pub fn pretty_print_delta_with(
  opts : PrettyPrintOptions,
  d : @diff.ReprDelta,
) -> String {
  let delta = prune_delta(opts, d.delta())
  print_content(no_wrap(render_delta(opts, delta)))
}

///|
/// Pretty-print a `ReprDelta` using `default_pretty_print_options`.
pub fn pretty_print_delta(d : @diff.ReprDelta) -> String {
  pretty_print_delta_with(default_pretty_print_options, d)
}
