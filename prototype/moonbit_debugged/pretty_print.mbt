///|
pub(all) struct PrettyPrintOptions {
  max_depth : Int?
  compact_threshold : Int
  use_ansi : Bool
} derive(Show, Eq)

///|
pub let default_pretty_print_options : PrettyPrintOptions = {
  max_depth: Some(4),
  compact_threshold: 8,
  use_ansi: true,
}

///|
fn label_adds_depth(label : Label) -> Bool {
  match label {
    LProp(_) | LAssocProp => false
    _ => true
  }
}

///|
fn delta_adds_depth(delta : Delta[Label]) -> Bool {
  match delta {
    Same(label) | Subtree(label) => label_adds_depth(label)
    _ => false
  }
}

///|
fn prune_repr_tree(
  opts : PrettyPrintOptions,
  tree : Tree[Label],
) -> Tree[Label] {
  match opts.max_depth {
    None => tree
    Some(depth) =>
      prune_tree(tree, replacement=LOmitted, counts=label_adds_depth, depth~)
  }
}

///|
fn prune_delta_tree(
  opts : PrettyPrintOptions,
  tree : Tree[Delta[Label]],
) -> Tree[Delta[Label]] {
  match opts.max_depth {
    None => tree
    Some(depth) =>
      prune_tree(
        tree,
        replacement=Same(LOmitted),
        counts=delta_adds_depth,
        depth~,
      )
  }
}

///|
fn label_size(label : Label) -> Int {
  match label {
    LInt(_) => 1
    LDouble(_) => 1
    LBool(_) => 1
    LChar(_) => 1
    LString(s) => if s.length() <= 15 { 1 } else { 2 }
    LArray => 1
    LRecord => 2
    LProp(name) => if name.length() <= 15 { 0 } else { 1 }
    LApp(name) => if name.length() <= 15 { 1 } else { 2 }
    LOpaque(name) => if name.length() <= 15 { 1 } else { 2 }
    LLiteral(s) => if s.length() <= 15 { 1 } else { 2 }
    LAssoc(_) => 2
    LAssocProp => 0
    LOmitted => 0
  }
}

///|
fn delta_size(delta : Delta[Label]) -> Int {
  match delta {
    Same(label) | Subtree(label) => label_size(label)
    _ => 0
  }
}

///|
fn measure(root_size : Int, children : Array[Content]) -> Int {
  let mut total = root_size
  for c in children {
    total += c.size
  }
  total
}

///|
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
fn quote_string_literal(s : String) -> String {
  s.escape()
}

///|
fn pretty_print_label(name : String) -> String {
  if is_unquoted_key(name) {
    name
  } else {
    quote_string_literal(name)
  }
}

///|
fn pretty_print_repr_go(label : Label, children : Array[Content]) -> Content {
  match label {
    LInt(x) => leaf(x, needs_parens=x < 0)
    LDouble(x) => {
      let needs_parens = 1.0 / x < 0.0
      leaf(x, needs_parens~)
    }
    LBool(x) => leaf(x)
    LChar(x) => leaf(x)
    LString(x) => no_parens(verbatim(quote_string_literal(x)))
    LApp(name) => {
      let rendered_children = children.map(wrap).map(fn(c) { indent("  ", c) })
      let content = verbatim(name) +
        rendered_children.fold(init={ size: 0, lines: [] }, fn(acc, c) {
          acc + c
        })
      if children.length() > 0 {
        parens(content)
      } else {
        no_parens(content)
      }
    }
    LArray => comma_seq("[ ", " ]", children.map(no_wrap))
    LRecord => comma_seq("{ ", " }", children.map(no_wrap))
    LOpaque(name) =>
      if children.is_empty() {
        no_parens(surround("<", ">", verbatim(name)))
      } else {
        let body = verbatim(name + ":") +
          indent("  ", no_wrap(comma_seq("", "", children.map(no_wrap))))
        no_parens(surround("<", ">", body))
      }
    LLiteral(str) => no_parens(verbatim(str))
    LAssoc(name) =>
      no_parens(
        surround(
          "<",
          ">",
          verbatim(name + ":") +
          no_wrap(comma_seq("{ ", " }", children.map(no_wrap))),
        ),
      )
    LAssocProp =>
      match children {
        [key, val] => no_parens(surround("", ":", no_wrap(key)) + no_wrap(val))
        _ => empty_content()
      }
    LProp(name) =>
      match children {
        [val] =>
          no_parens(
            verbatim(pretty_print_label(name) + ":") +
            indent("  ", no_wrap(val)),
          )
        _ => empty_content()
      }
    LOmitted => parens(verbatim("..."))
  }
}

///|
fn ansi_green() -> String {
  "\u001b[32m"
}

///|
fn ansi_red() -> String {
  "\u001b[31m"
}

///|
fn ansi_reset() -> String {
  "\u001b[0m"
}

///|
fn mark_added(opts : PrettyPrintOptions, x : ContentParens) -> ContentParens {
  if opts.use_ansi {
    surround(ansi_green() + "+", ansi_reset(), x)
  } else {
    surround("+", "", x)
  }
}

///|
fn mark_removed(opts : PrettyPrintOptions, x : ContentParens) -> ContentParens {
  if opts.use_ansi {
    surround(ansi_red() + "-", ansi_reset(), x)
  } else {
    surround("-", "", x)
  }
}

///|
fn pretty_print_delta_go(
  opts : PrettyPrintOptions,
  delta : Delta[Label],
  children : Array[Content],
) -> Content {
  match delta {
    Same(label) => pretty_print_repr_go(label, children)
    Different =>
      match children {
        [left, right] =>
          no_parens(
            mark_removed(opts, no_wrap(left)) + mark_added(opts, no_wrap(right)),
          )
        _ => empty_content()
      }
    Extra1 =>
      match children {
        [x] => no_parens(mark_removed(opts, no_wrap(x)))
        _ => empty_content()
      }
    Extra2 =>
      match children {
        [x] => no_parens(mark_added(opts, no_wrap(x)))
        _ => empty_content()
      }
    Subtree(label) => pretty_print_repr_go(label, children)
  }
}

///|
pub fn pretty_print_repr_with(opts : PrettyPrintOptions, r : Repr) -> String {
  let tree = prune_repr_tree(opts, un_repr(r))
  let content = fold_tree(tree, fn(label, children) {
    with_resizing(
      label_size(label),
      opts.compact_threshold,
      fn(children) { pretty_print_repr_go(label, children) },
      children,
    )
  })
  print_content(no_wrap(content))
}

///|
pub fn pretty_print_repr(r : Repr) -> String {
  pretty_print_repr_with(default_pretty_print_options, r)
}

///|
pub fn pretty_print_delta_with(
  opts : PrettyPrintOptions,
  d : ReprDelta,
) -> String {
  let tree = prune_delta_tree(opts, un_repr_delta(d))
  let content = fold_tree(tree, fn(delta, children) {
    with_resizing(
      delta_size(delta),
      opts.compact_threshold,
      fn(children) { pretty_print_delta_go(opts, delta, children) },
      children,
    )
  })
  print_content(no_wrap(content))
}

///|
pub fn pretty_print_delta(d : ReprDelta) -> String {
  pretty_print_delta_with(default_pretty_print_options, d)
}
