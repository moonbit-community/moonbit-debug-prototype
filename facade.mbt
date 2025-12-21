///|
/// Re-export `Repr` and constructor-argument helpers from `@repr`.
/// Use `Repr::int(x)`, `Repr::string(s)`, etc. to construct values.
pub using @repr {type Repr, type CtorArg}

///|
/// Diffing (forwarded to `@diff`).
pub let default_diff_options : @diff.DiffOptions = @diff.default_diff_options

///|
pub fn diff_options(max_relative_error~ : Double) -> @diff.DiffOptions {
  { max_relative_error, }
}

///|
pub fn diff_repr_with(
  opts : @diff.DiffOptions,
  x : @repr.Repr,
  y : @repr.Repr,
) -> @diff.ReprDelta {
  @diff.diff_repr_with(opts, x, y)
}

///|
pub fn diff_repr(x : @repr.Repr, y : @repr.Repr) -> @diff.ReprDelta {
  @diff.diff_repr(x, y)
}

///|
/// Pretty-printing (forwarded to `@pp`).
pub let default_pretty_print_options : @pp.PrettyPrintOptions = @pp.default_pretty_print_options

///|
pub fn pretty_print_options(
  max_depth~ : Int?,
  compact_threshold~ : Int,
  use_ansi~ : Bool,
) -> @pp.PrettyPrintOptions {
  { max_depth, compact_threshold, use_ansi }
}

///|
pub fn pretty_print_repr_with(
  opts : @pp.PrettyPrintOptions,
  r : @repr.Repr,
) -> String {
  @pp.pretty_print_repr_with(opts, r)
}

///|
pub fn pretty_print_repr(r : @repr.Repr) -> String {
  @pp.pretty_print_repr(r)
}

///|
pub fn pretty_print_delta_with(
  opts : @pp.PrettyPrintOptions,
  d : @diff.ReprDelta,
) -> String {
  @pp.pretty_print_delta_with(opts, d)
}

///|
pub fn pretty_print_delta(d : @diff.ReprDelta) -> String {
  @pp.pretty_print_delta(d)
}
