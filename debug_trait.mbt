///|
/// Convert a value into a structural `Repr` for pretty-printing and diffing.
pub(open) trait Debug {
  debug(Self) -> @repr.Repr
}

///|
/// Build a `Repr` for any `T` that implements `Debug`.
pub fn[T : Debug] debug(x : T) -> @repr.Repr {
  T::debug(x)
}

///|
/// Pretty-print a value with optional parameters.
pub fn[T : Debug] pretty_print(
  x : T,
  max_depth? : Int,
  compact_threshold? : Int,
  use_ansi? : Bool,
) -> String {
  @pp.pretty_print_repr(debug(x), max_depth?, compact_threshold?, use_ansi?)
}

///|
/// Diff two values by diffing their `Repr` with optional float tolerance.
pub fn[T : Debug] diff(
  x : T,
  y : T,
  max_relative_error? : Double,
) -> @diff.ReprDelta {
  @diff.diff_repr(debug(x), debug(y), max_relative_error?)
}

///|
/// Pretty-print the diff between two values with optional parameters.
pub fn[T : Debug] pretty_print_diff(
  x : T,
  y : T,
  max_depth? : Int,
  compact_threshold? : Int,
  use_ansi? : Bool,
  max_relative_error? : Double,
) -> String {
  @pp.pretty_print_delta(
    diff(x, y, max_relative_error?),
    max_depth?,
    compact_threshold?,
    use_ansi?,
  )
}
