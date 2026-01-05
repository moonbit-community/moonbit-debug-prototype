///|
/// Rendered content with line layout and paren preference.
///
/// This is an internal implementation detail of `pretty_print`.
/// Users should rely on `pretty_print_repr` / `pretty_print_delta`.
priv struct Content {
  size : Int
  lines : Array[String]
  needs_parens : Bool
}

///|
/// Rendered content without paren preference metadata.
///
/// This is an internal implementation detail of `pretty_print`.
priv struct ContentParens {
  size : Int
  lines : Array[String]
}

///|

///|
impl Add for ContentParens with add(self, other) {
  { size: self.size + other.size, lines: self.lines + other.lines }
}

///|
/// Empty content value.
fn empty_content() -> Content {
  { size: 0, lines: [], needs_parens: false }
}

///|
/// Single literal token as a `ContentParens`.
fn verbatim(x : String) -> ContentParens {
  { size: 1, lines: [x] }
}

///|
/// Build a `ContentParens` from explicit size and lines.
fn content_parens(size : Int, lines : Array[String]) -> ContentParens {
  { size, lines }
}

///|
/// Render any `Show` value as a leaf content node.
fn[T : Show] leaf(x : T, needs_parens? : Bool = false) -> Content {
  { size: 1, lines: [repr(x)], needs_parens }
}

///|
/// Render any `Show` value as a leaf with a type suffix.

///|
/// Map a transformation over the lines of `ContentParens`.
fn with_lines(
  r : ContentParens,
  f : (Array[String]) -> Array[String],
) -> ContentParens {
  { size: r.size, lines: f(r.lines) }
}

///|
/// Map a transformation over the lines of `Content`.
fn Content::with_lines_content(
  r : Content,
  f : (Array[String]) -> Array[String],
) -> Content {
  { size: r.size, lines: f(r.lines), needs_parens: r.needs_parens }
}

///|
/// Surround multi-line content with a prefix/suffix, preserving layout.
fn surround_lines(
  start : String,
  finish : String,
  lines : Array[String],
) -> Array[String] {
  match lines {
    [] => [start + finish]
    [item] => [start + item + finish]
    [first, ..] => {
      let n = lines.length()
      let middle = if n <= 2 { [] } else { lines[1:n - 1].to_array() }
      let last = lines[n - 1]
      [start + first] + middle + [last + finish]
    }
  }
}

///|
/// Surround content with a prefix/suffix, preserving layout.
fn surround(
  start : String,
  finish : String,
  r : ContentParens,
) -> ContentParens {
  with_lines(r, fn(lines) { surround_lines(start, finish, lines) })
}

///|
/// Convert `Content` to `ContentParens` without adding parentheses.
fn Content::no_wrap(c : Content) -> ContentParens {
  { size: c.size, lines: c.lines }
}

///|
/// Mark a content chunk as needing parentheses when embedded.
fn parens(r : ContentParens) -> Content {
  { size: r.size, lines: r.lines, needs_parens: true }
}

///|
/// Mark a content chunk as not needing parentheses when embedded.
fn no_parens(r : ContentParens) -> Content {
  { size: r.size, lines: r.lines, needs_parens: false }
}

///|
/// Compact multi-line output into a single line when possible.
#warnings("-deprecated")
fn compact_lines(lines : Array[String]) -> Array[String] {
  match lines {
    [] => []
    [x] => [x]
    [first, ..] => {
      let n = lines.length()
      let middle : ArrayView[String] = if n <= 2 { [] } else { lines[1:n - 1] }
      let last = lines[n - 1]
      let parts : Array[StringView] = [first]
      for m in middle {
        parts.push(m.trim_space())
      }
      parts.push(last.trim_space())
      [parts.join(" "[:])]
    }
  }
}

///|
/// Compact a `Content` value.
fn Content::compact(r : Content) -> Content {
  r.with_lines_content(compact_lines)
}

///|
/// Indent every line by a fixed prefix.
fn indent(prefix : String, r : ContentParens) -> ContentParens {
  with_lines(r, fn(lines) { lines.map(fn(line) { prefix + line }) })
}

///|
/// Join content chunks with commas and consistent indentation.
fn comma_seq_lines(
  begin : String,
  end : String,
  contents : Array[Array[String]],
) -> Array[String] {
  fn spacer(begin : String) -> String {
    " ".repeat(begin.length())
  }

  let lines = match contents {
    [] => [begin + end]
    [item] => surround_lines(begin, end, item)
    [first, ..] => {
      let n = contents.length()
      let middle = if n <= 2 { [] } else { contents[1:n - 1].to_array() }
      let last = contents[n - 1]
      let space = spacer(begin)
      let middle_lines = middle.fold(init=[], fn(acc, item) {
        acc + surround_lines(space, ",", item)
      })
      surround_lines(begin, ",", first) +
      middle_lines +
      surround_lines(space, end, last)
    }
  }
  lines.filter(fn(line) { line != "" })
}

///|
/// Build a comma-separated sequence as `Content`.
fn comma_seq(
  begin : String,
  end : String,
  contents : Array[ContentParens],
) -> Content {
  let mut size = 0
  for c in contents {
    size += c.size
  }
  {
    size,
    lines: comma_seq_lines(begin, end, contents.map(fn(c) { c.lines })),
    needs_parens: false,
  }
}

///|
/// Convert content into a final `String` with newline separators.
fn print_content(r : ContentParens) -> String {
  r.lines.join("\n"[:])
}

///|
/// Total “size” of a node (root + children), used for compact decisions.
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
    f(children).compact()
  } else {
    f(children)
  }
}
