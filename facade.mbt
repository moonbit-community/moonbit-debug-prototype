///|
/// Re-export `Repr` and smart constructors from `@repr`.
/// Use `Repr::int(x)`, `Repr::string(s)`, etc. to construct values.
pub using @repr {type Repr}

///|
/// Diffing (forwarded to `@diff`).
pub using @diff {type ReprDelta, diff_repr}

///|
/// Pretty-printing (forwarded to `@pp`).
pub using @pp {pretty_print_repr, pretty_print_delta}
