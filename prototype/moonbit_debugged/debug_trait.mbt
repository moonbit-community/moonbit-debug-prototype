///|
pub trait Debug {
  debug(Self) -> Repr
}

///|
pub fn[T : Debug] debug(x : T) -> Repr {
  T::debug(x)
}

///|
pub fn[T : Debug] pretty_print(x : T) -> String {
  pretty_print_repr(debug(x))
}

///|
pub fn[T : Debug] pretty_print_with(opts : PrettyPrintOptions, x : T) -> String {
  pretty_print_repr_with(opts, debug(x))
}

///|
pub fn[T : Debug] diff(x : T, y : T) -> ReprDelta {
  diff_repr(debug(x), debug(y))
}

///|
pub fn[T : Debug] diff_with(opts : DiffOptions, x : T, y : T) -> ReprDelta {
  diff_repr_with(opts, debug(x), debug(y))
}

///|
pub fn[T : Debug] pretty_print_diff(x : T, y : T) -> String {
  pretty_print_delta(diff(x, y))
}

///|
pub fn[T : Debug] pretty_print_diff_with(
  opts : PrettyPrintOptions,
  x : T,
  y : T,
) -> String {
  pretty_print_delta_with(opts, diff(x, y))
}
