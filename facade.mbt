///|
/// Repr constructors (forwarded to `@repr`).
pub fn int(x : Int) -> @repr.Repr {
  @repr.int(x)
}

///|
pub fn double(x : Double) -> @repr.Repr {
  @repr.double(x)
}

///|
pub fn bool(x : Bool) -> @repr.Repr {
  @repr.bool(x)
}

///|
pub fn char(x : Char) -> @repr.Repr {
  @repr.char(x)
}

///|
pub fn string(x : String) -> @repr.Repr {
  @repr.string(x)
}

///|
pub fn array(xs : Array[@repr.Repr]) -> @repr.Repr {
  @repr.array(xs)
}

///|
pub fn record(fields : Array[(String, @repr.Repr)]) -> @repr.Repr {
  @repr.record(fields)
}

///|
pub fn ctor(name : String, args : Array[@repr.Repr]) -> @repr.Repr {
  @repr.ctor(name, args)
}

///|
pub fn arg(label : String, value : @repr.Repr) -> @repr.Repr {
  @repr.arg(label, value)
}

///|
pub fn opaque_child(name : String, child : @repr.Repr) -> @repr.Repr {
  @repr.opaque_child(name, child)
}

///|
pub fn opaque_(name : String) -> @repr.Repr {
  @repr.opaque_(name)
}

///|
pub fn opaque_literal(name : String, value : String) -> @repr.Repr {
  @repr.opaque_literal(name, value)
}

///|
pub fn collection(name : String, contents : Array[@repr.Repr]) -> @repr.Repr {
  @repr.collection(name, contents)
}

///|
pub fn assoc(
  name : String,
  contents : Array[(@repr.Repr, @repr.Repr)],
) -> @repr.Repr {
  @repr.assoc(name, contents)
}

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
