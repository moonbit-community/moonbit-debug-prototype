# moonbit-community/debug

An experimental `Debug` + `diff` + pretty-printer library for MoonBit. We plan 
to add this to the standard library when it is more mature.

It provides:

* A `Debug` trait that turns values into a structural `Repr`
* A tree-based `diff` (`ReprDelta`) with configurable float tolerance
* A pretty printer for both `Repr` and `ReprDelta` (optionally with ANSI marks)
* A binary to auto-generate `Debug` implementations for your types

Goals: 

- A way to debug values and show the diff, with pretty-printing

- Replacing Some Roles of `Show` and `ToJson`

  The current `Show` trait produces output that is not suitable for debugging, as it lacks indentation and line breaks.  
  The `ToJson` trait produces JSON, which is more readable with `@json.inspect` but not ideal for MoonBit-specific types (e.g., enums).  
  It can also confuse users who expect `ToJson` to produce structured data rather than a debug representation.

  With the introduction of `Debug`, the `Show` trait can focus on producing specialized output (such as `Json::stringify`, `String::to_string`, etc.), and `derive(Show)` will be deprecated.


Non-goals:

- Deserializing from `Repr` back to original values
- Output a valid moonbit code representation

## Project structure

The current pre-build command design forces us to separate the build script (written in MoonBit) 
into its own module and use a local binary dependency to invoke it. 
Therefore, the project is structured as follows:

* `debug/`: the main library module
* `auto_derive/`: the build script module that generates `Debug` implementations
* `auto_derive_example/`: an example module that uses the `debug` library and build script to generate code

## Quickstart

Run the small demo:

```bash
moon run cmd/main
```

In another package, import this module in `moon.pkg.json` :

```json
{
  "import": [{ "path": "moonbit-community/debug", "alias": "dbg" }]
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

Use `record` , `ctor` , `array` , and friends to build a `Repr` :

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

## Auto deriving `Debug`

To automatically generate `Debug` implementations for your types:

1. add `moonbit-community/debug_deriving` as a binary dependency in your `moon.mod.json` 
2. add a `pre-build` command that runs the `debug_deriving` binary, for example:

```json
{
  "pre-build": [
    {
      "command": "$mod_dir/.mooncakes/moonbit-community/debug_deriving/debug_deriving $input $output",
      "input": "input.mbt",
      "output": "output.mbt"
    }
  ]
}
``` 

3. in your `input.mbt`, add `#debug.derive` attribute to your types:

```mbt
#debug.derive
struct Pos(Int, Int)
```

## Options

All options are passed directly as optional parameters to functions:

### Pretty printing

* `max_depth?`: optional depth limit; omit for default (4), or pass `max_depth=n` to prune
* `compact_threshold?`: controls single-line vs multi-line rendering (default: 8)
* `use_ansi?`: enables `+`/`-` with ANSI colors in diffs (default: true)

### Diffing

* `max_relative_error?`: float tolerance for comparing `Double` values

See `docs_test.mbt` and `examples_test.mbt` for runnable, snapshot-based
examples.

## Doctest examples

```mbt check
///|
test {
  inspect(pretty_print([1, 2, 3]), content="[ 1, 2, 3 ]")
  inspect(
    pretty_print_diff(1, 2, compact_threshold=100, use_ansi=false),
    content="-1 +2",
  )
}
```
