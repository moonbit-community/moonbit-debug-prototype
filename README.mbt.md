# dii_user/moonbit_debugged

A tiny `Debug` + `diff` + pretty-printer library for MoonBit.

It provides:

- A `Debug` trait that turns values into a structural `Repr`
- A tree-based `diff` (`ReprDelta`) with configurable float tolerance
- A pretty printer for both `Repr` and `ReprDelta` (optionally with ANSI marks)

## Quickstart

Run the small demo:

```bash
moon run cmd/main
```

In another package, import this module in `moon.pkg.json`:

```json
{
  "import": [{ "path": "dii_user/moonbit_debugged", "alias": "dbg" }]
}
```

Then call:

```mbt
///|
fn show_examples {
  println(@dbg.pretty_print([1, 2, 3]))
  println(@dbg.pretty_print_diff(Some(1), Some(2)))
}
```

## Implement `Debug` for your own types

Use `record`, `ctor`, `array`, and friends to build a `Repr`:

```mbt
///|
struct Person {
  name : String
  age : Int
}

///|
pub impl @dbg.Debug for Person with debug(self) {
  @dbg.record([("name", @dbg.debug(self.name)), ("age", @dbg.debug(self.age))])
}
```

## Options

### Pretty printing (`PrettyPrintOptions`)

- `PrettyPrintOptions` is defined in `dii_user/moonbit_debugged/pretty_print`.
  If you only import `dii_user/moonbit_debugged`, use `pretty_print_options(...)`
  to construct it.
- `max_depth`: prune large values (`Some(n)`), or disable with `None`
- `compact_threshold`: controls single-line vs multi-line rendering
- `use_ansi`: enables `+`/`-` with ANSI colors in diffs

### Diffing (`DiffOptions`)

`DiffOptions` is defined in `dii_user/moonbit_debugged/diff`. If you only import
`dii_user/moonbit_debugged`, use `diff_options(...)` to construct it.

Use `diff_with` / `diff_repr_with` to set float tolerance via
`max_relative_error`.

See `docs_test.mbt` and `examples_test.mbt` for runnable, snapshot-based
examples.

## Doctest examples

```mbt check
///|
test {
  inspect(pretty_print([1, 2, 3]), content="[ 1, 2, 3 ]")
  let opts = pretty_print_options(
    max_depth=None,
    compact_threshold=100,
    use_ansi=false,
  )
  inspect(pretty_print_delta_with(opts, diff(1, 2)), content="-1 +2")
}
```
