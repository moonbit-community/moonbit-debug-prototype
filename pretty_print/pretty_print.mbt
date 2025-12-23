///|
/// Default max depth for pruning.
let default_max_depth : Int = 4

///|
/// Default compact threshold for layout decisions.
let default_compact_threshold : Int = 8

///|
/// Default ANSI color setting.
let default_use_ansi : Bool = true

///|
/// Prune a `Repr` using max_depth (replacing with `Omitted`).
fn prune_repr_info(max_depth : Int?, info : @repr.Repr) -> @repr.Repr {
  match max_depth {
    None => info
    Some(depth) => info.prune_info(depth~)
  }
}

///|
/// Prune a `DebugDelta` using max_depth (replacing with `Same(Omitted, [])`).
fn prune_delta(max_depth : Int?, delta : @diff.DebugDelta) -> @diff.DebugDelta {
  fn go(d : Int, node : @diff.DebugDelta) -> @diff.DebugDelta {
    match node {
      Same(label, children) =>
        if d <= 0 {
          if children.is_empty() {
            node
          } else if !label.info_adds_depth() {
            Same(label, children.map(fn(child) { go(d, child) }))
          } else {
            Same(@repr.Repr::omitted(), [])
          }
        } else {
          let next_depth = if label.info_adds_depth() { d - 1 } else { d }
          Same(label, children.map(fn(child) { go(next_depth, child) }))
        }
      Different(left, right) =>
        if d <= 0 {
          Same(@repr.Repr::omitted(), [])
        } else {
          Different(left.prune_info(depth=d), right.prune_info(depth=d))
        }
      Extra1(x) =>
        if d <= 0 {
          Same(@repr.Repr::omitted(), [])
        } else {
          Extra1(x.prune_info(depth=d))
        }
      Extra2(x) =>
        if d <= 0 {
          Same(@repr.Repr::omitted(), [])
        } else {
          Extra2(x.prune_info(depth=d))
        }
    }
  }

  match max_depth {
    None => delta
    Some(depth) => go(Int::max(1, depth), delta)
  }
}

///|
/// Heuristic "size" of a node for compact-vs-multiline decisions.
fn info_size(info : @repr.Repr) -> Int {
  match info {
    UnitLit => 1
    Fixnum(_) => 1
    DoubleLit(_) => 1
    FloatLit(_) => 1
    BoolLit(_) => 1
    CharLit(_) => 1
    StringLit(s) => if s.length() <= 15 { 1 } else { 2 }
    Tuple(_) => 1
    Array(_) => 1
    Record(_) => 2
    RecordField(name, _) => if name.length() <= 15 { 0 } else { 1 }
    EnumLabeledArg(name, _) => if name.length() <= 15 { 0 } else { 1 }
    Enum(name, _) => if name.length() <= 15 { 1 } else { 2 }
    Opaque(name, _) => if name.length() <= 15 { 1 } else { 2 }
    Literal(s) => if s.length() <= 15 { 1 } else { 2 }
    Map(_) => 2
    MapEntry(_, _) => 0
    Omitted => 0
  }
}

///|
/// Heuristic "size" of a delta for compact-vs-multiline decisions.
fn delta_root_size(delta : @diff.DebugDelta) -> Int {
  match delta {
    Same(label, _) => info_size(label)
    _ => 0
  }
}

///|
/// Render compactly when the measured size stays under `threshold`.
fn with_resizing(
  root_size : Int,
  threshold : Int,
  f : (Array[@printer.Content]) -> @printer.Content,
  children : Array[@printer.Content],
) -> @printer.Content {
  @printer.with_resizing(root_size, threshold, f, children)
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
  children : Array[@printer.Content],
) -> @printer.Content {
  match label {
    UnitLit => @printer.comma_seq("(", ")", [])
    Fixnum(s) => {
      let needs_parens = s.length() > 0 && s.code_unit_at(0) == '-'
      @printer.no_parens(
        @printer.content_parens(if needs_parens { 1 } else { 0 }, [s]),
      )
    }
    DoubleLit(x) => {
      let needs_parens = 1.0 / x < 0.0
      @printer.leaf(x, needs_parens~)
    }
    FloatLit(x) => {
      let needs_parens : Bool = (1.0 : Float) / x < (0.0 : Float)
      @printer.leaf(x, needs_parens~)
    }
    BoolLit(x) => @printer.leaf(x)
    CharLit(x) => @printer.leaf(x)
    StringLit(x) =>
      @printer.no_parens(@printer.verbatim(quote_string_literal(x)))
    Tuple(_) => @printer.comma_seq("(", ")", children.map(x => x.no_wrap()))
    Enum(name, _) =>
      match children {
        [] => @printer.no_parens(@printer.verbatim(name))
        _ =>
          if name == "Tuple" {
            @printer.comma_seq("(", ")", children.map(x => x.no_wrap()))
          } else {
            @printer.comma_seq(name + "(", ")", children.map(x => x.no_wrap()))
          }
      }
    Array(_) => @printer.comma_seq("[ ", " ]", children.map(x => x.no_wrap()))
    Record(_) => @printer.comma_seq("{ ", " }", children.map(x => x.no_wrap()))
    Opaque(name, _) =>
      if children.is_empty() {
        @printer.no_parens(@printer.surround("<", ">", @printer.verbatim(name)))
      } else {
        let body = @printer.verbatim(name + ":") +
          @printer.indent(
            "  ",
            @printer.comma_seq("", "", children.map(x => x.no_wrap())).no_wrap(),
          )
        @printer.no_parens(@printer.surround("<", ">", body))
      }
    Literal(str) => @printer.no_parens(@printer.verbatim(str))
    Map(_) => @printer.comma_seq("{ ", " }", children.map(x => x.no_wrap()))
    MapEntry(_, _) =>
      match children {
        [key, val] =>
          @printer.no_parens(
            @printer.surround("", ":", key.no_wrap()) + val.no_wrap(),
          )
        _ => @printer.empty_content()
      }
    EnumLabeledArg(name, _) =>
      match children {
        [val] =>
          match val.lines {
            [] => @printer.empty_content()
            [first] =>
              @printer.no_parens(
                @printer.content_parens(1 + val.size, [name + "=" + first]),
              )
            [first, ..] => {
              let n = val.lines.length()
              let rest = if n <= 1 { [] } else { val.lines[1:n].to_array() }
              @printer.no_parens(
                @printer.content_parens(
                  1 + val.size,
                  [name + "=" + first] + rest,
                ),
              )
            }
          }
        _ => @printer.empty_content()
      }
    RecordField(name, _) =>
      match children {
        [val] =>
          @printer.no_parens(
            @printer.verbatim(pretty_print_label(name) + ":") +
            @printer.indent("  ", val.no_wrap()),
          )
        _ => @printer.empty_content()
      }
    Omitted => @printer.parens(@printer.verbatim("..."))
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
fn mark_added(
  use_ansi : Bool,
  x : @printer.ContentParens,
) -> @printer.ContentParens {
  if use_ansi {
    @printer.surround(ansi_green() + "+", ansi_reset(), x)
  } else {
    @printer.surround("+", "", x)
  }
}

///|
/// Mark removed content with `-` (and optionally ANSI color).
fn mark_removed(
  use_ansi : Bool,
  x : @printer.ContentParens,
) -> @printer.ContentParens {
  if use_ansi {
    @printer.surround(ansi_red() + "-", ansi_reset(), x)
  } else {
    @printer.surround("-", "", x)
  }
}

///|
/// Render a `Repr` as `Content` with resizing decisions.
fn render_repr(
  compact_threshold : Int,
  use_ansi : Bool,
  info : @repr.Repr,
) -> @printer.Content {
  let label = info.shallow()
  let children = info
    .children()
    .map(fn(child) { render_repr(compact_threshold, use_ansi, child) })
  with_resizing(
    info_size(label),
    compact_threshold,
    fn(children) { pretty_print_repr_go(label, children) },
    children,
  )
}

///|
/// Render a `DebugDelta` as `Content` with resizing decisions.
fn render_delta(
  compact_threshold : Int,
  use_ansi : Bool,
  delta : @diff.DebugDelta,
) -> @printer.Content {
  match delta {
    Same(label, children_delta) => {
      let children = children_delta.map(fn(child) {
        render_delta(compact_threshold, use_ansi, child)
      })
      with_resizing(
        delta_root_size(delta),
        compact_threshold,
        fn(children) { pretty_print_repr_go(label, children) },
        children,
      )
    }
    Different(left, right) => {
      let children : Array[@printer.Content] = [
        render_repr(compact_threshold, use_ansi, left),
        render_repr(compact_threshold, use_ansi, right),
      ]
      with_resizing(
        0,
        compact_threshold,
        fn(children) {
          match children {
            [left, right] =>
              @printer.no_parens(
                mark_removed(use_ansi, left.no_wrap()) +
                mark_added(use_ansi, right.no_wrap()),
              )
            _ => @printer.empty_content()
          }
        },
        children,
      )
    }
    Extra1(x) => {
      let children : Array[@printer.Content] = [
        render_repr(compact_threshold, use_ansi, x),
      ]
      with_resizing(
        0,
        compact_threshold,
        fn(children) {
          match children {
            [x] => @printer.no_parens(mark_removed(use_ansi, x.no_wrap()))
            _ => @printer.empty_content()
          }
        },
        children,
      )
    }
    Extra2(x) => {
      let children : Array[@printer.Content] = [
        render_repr(compact_threshold, use_ansi, x),
      ]
      with_resizing(
        0,
        compact_threshold,
        fn(children) {
          match children {
            [x] => @printer.no_parens(mark_added(use_ansi, x.no_wrap()))
            _ => @printer.empty_content()
          }
        },
        children,
      )
    }
  }
}

///|
/// Pretty-print a `Repr` with optional parameters.
pub fn pretty_print_repr(
  r : @repr.Repr,
  max_depth? : Int,
  compact_threshold? : Int,
  use_ansi? : Bool,
) -> String {
  let max_depth : Int? = match max_depth {
    Some(_) => max_depth
    None => Some(default_max_depth)
  }
  let compact_threshold = compact_threshold.unwrap_or(default_compact_threshold)
  let use_ansi = use_ansi.unwrap_or(default_use_ansi)
  let info = prune_repr_info(max_depth, r)
  @printer.print_content(
    render_repr(compact_threshold, use_ansi, info).no_wrap(),
  )
}

///|
/// Pretty-print a `ReprDelta` with optional parameters.
pub fn pretty_print_delta(
  d : @diff.ReprDelta,
  max_depth? : Int,
  compact_threshold? : Int,
  use_ansi? : Bool,
) -> String {
  let max_depth : Int? = match max_depth {
    Some(_) => max_depth
    None => Some(default_max_depth)
  }
  let compact_threshold = compact_threshold.unwrap_or(default_compact_threshold)
  let use_ansi = use_ansi.unwrap_or(default_use_ansi)
  let delta = prune_delta(max_depth, d.delta())
  @printer.print_content(
    render_delta(compact_threshold, use_ansi, delta).no_wrap(),
  )
}
