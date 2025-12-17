///|
fn print_opts() -> PrettyPrintOptions {
  { max_depth: None, compact_threshold: 100, use_ansi: false }
}

///|
test "docs: building Repr manually" {
  let r = @repr.record([
    ("answer", @repr.int(42)),
    ("xs", @repr.array([@repr.int(1), @repr.int(2), @repr.int(3)])),
    ("tag", @repr.ctor("Ok", [@repr.string("done")])),
  ])
  inspect(
    pretty_print_repr_with(print_opts(), r),
    content="{ answer: 42, xs: [ 1, 2, 3 ], tag: Ok(\"done\") }",
  )
}

///|
test "docs: record keys are quoted when needed" {
  let r = @repr.record([
    ("snake_case_ok", @repr.int(1)),
    ("with space", @repr.int(2)),
    ("k-v", @repr.int(3)),
    ("CamelCase", @repr.int(4)),
  ])
  inspect(
    pretty_print_repr_with(print_opts(), r),
    content="{ snake_case_ok: 1, \"with space\": 2, \"k-v\": 3, \"CamelCase\": 4 }",
  )
}

///|
test "docs: compact_threshold controls single-line vs multi-line" {
  let xs = @repr.array([@repr.int(1), @repr.int(2), @repr.int(3)])
  let compact = pretty_print_repr(xs)
  let expanded = pretty_print_repr_with(
    { max_depth: None, compact_threshold: 0, use_ansi: false },
    xs,
  )
  inspect(compact, content="[ 1, 2, 3 ]")
  inspect(
    expanded,
    content=(
      #|[ 1,
      #|  2,
      #|  3 ]
    ),
  )
}

///|
test "docs: diff_repr_with can ignore tiny float changes" {
  let strict : @diff.DiffOptions = { max_relative_error: 0.0 }
  let tolerant : @diff.DiffOptions = { max_relative_error: 1.0e-12 }
  let print_opts = print_opts()
  let x = @repr.double(1.0)
  let y = @repr.double(1.0 + 1.0e-13)
  inspect(
    (
      pretty_print_delta_with(print_opts, @diff.diff_repr_with(strict, x, y)),
      pretty_print_delta_with(print_opts, @diff.diff_repr_with(tolerant, x, y)),
    ),
    content="(\"-1 +1.0000000000001\", \"1\")",
  )
}
