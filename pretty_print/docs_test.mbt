///|
enum Tag {
  Ok(String)
}

///|
struct Example {
  answer : Int
  xs : Array[Int]
  tag : Tag
}

///|
fn tag_repr(tag : Tag) -> @repr.Repr {
  match tag {
    Ok(value) => @repr.Repr::ctor("Ok", [(None, @repr.Repr::string(value))])
  }
}

///|
fn example_repr(example : Example) -> @repr.Repr {
  @repr.Repr::record({
    "answer": @repr.Repr::int(example.answer),
    "xs": @repr.Repr::array(example.xs.map(fn(x) { @repr.Repr::int(x) })),
    "tag": tag_repr(example.tag),
  })
}

///|
test "docs: custom type pretty_print" {
  let sample : Example = { answer: 42, xs: [1, 2, 3], tag: Ok("done") }
  let r = example_repr(sample)
  inspect(
    pretty_print_repr(r, compact_threshold=100, use_ansi=false),
    content="{ answer: 42, xs: [ 1, 2, 3 ], tag: Ok(\"done\") }",
  )
}

///|
struct WeirdKeys {
  snake_case_ok : Int
  with_space : Int
  k_dash_v : Int
  camel_case : Int
}

///|
fn weird_keys_repr(value : WeirdKeys) -> @repr.Repr {
  @repr.Repr::record({
    "snake_case_ok": @repr.Repr::int(value.snake_case_ok),
    "with space": @repr.Repr::int(value.with_space),
    "k-v": @repr.Repr::int(value.k_dash_v),
    "CamelCase": @repr.Repr::int(value.camel_case),
  })
}

///|
test "docs: record keys are quoted when needed" {
  let sample : WeirdKeys = {
    snake_case_ok: 1,
    with_space: 2,
    k_dash_v: 3,
    camel_case: 4,
  }
  let r = weird_keys_repr(sample)
  inspect(
    pretty_print_repr(r, compact_threshold=100, use_ansi=false),
    content="{ snake_case_ok: 1, \"with space\": 2, \"k-v\": 3, \"CamelCase\": 4 }",
  )
}

///|
struct Numbers {
  xs : Array[Int]
}

///|
fn numbers_repr(value : Numbers) -> @repr.Repr {
  @repr.Repr::array(value.xs.map(fn(x) { @repr.Repr::int(x) }))
}

///|
test "docs: compact_threshold controls single-line vs multi-line" {
  let sample : Numbers = { xs: [1, 2, 3] }
  let r = numbers_repr(sample)
  let compact = pretty_print_repr(r)
  let expanded = pretty_print_repr(r, compact_threshold=0, use_ansi=false)
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
enum Shape {
  Point(x~ : Int, y~ : Int)
  Line(Shape, Shape)
}

///|
fn shape_repr(shape : Shape) -> @repr.Repr {
  match shape {
    Point(x~, y~) =>
      @repr.Repr::ctor("Point", [
        (Some("x"), @repr.Repr::int(x)),
        (Some("y"), @repr.Repr::int(y)),
      ])
    Line(a, b) =>
      @repr.Repr::ctor("Line", [(None, shape_repr(a)), (None, shape_repr(b))])
  }
}

///|
test "docs: labeled enum arguments are printed" {
  let sample : Shape = Line(Point(x=1, y=2), Point(x=3, y=4))
  let r = shape_repr(sample)
  inspect(
    pretty_print_repr(r, compact_threshold=100, use_ansi=false),
    content="Line(Point(x=1, y=2), Point(x=3, y=4))",
  )
}

///|
struct DictExample {
  entries : Array[(String, Int)]
}

///|
fn dict_repr(value : DictExample) -> @repr.Repr {
  @repr.Repr::dict(
    value.entries.map(fn(pair) {
      let (k, v) = pair
      (@repr.Repr::string(k), @repr.Repr::int(v))
    }),
  )
}

///|
test "docs: dict prints as k: v pairs" {
  let sample : DictExample = { entries: [("a", 1), ("b", 2)] }
  let r = dict_repr(sample)
  inspect(
    pretty_print_repr(r, compact_threshold=100, use_ansi=false),
    content="{ \"a\": 1, \"b\": 2 }",
  )
}

///|
struct OpaqueExample {
  label : String
  xs : Array[Int]
}

///|
fn opaque_repr(value : OpaqueExample) -> @repr.Repr {
  @repr.Repr::opaque_(value.label, [
    @repr.Repr::array(value.xs.map(fn(x) { @repr.Repr::int(x) })),
  ])
}

///|
test "docs: opaque wrappers show tag and children" {
  let sample : OpaqueExample = { label: "Vec", xs: [1, 2] }
  let r = opaque_repr(sample)
  inspect(
    pretty_print_repr(r, compact_threshold=100, use_ansi=false),
    content="<Vec: [ 1, 2 ]>",
  )
}

///|
struct FloatSample {
  value : Double
}

///|
fn float_repr(sample : FloatSample) -> @repr.Repr {
  @repr.Repr::double(sample.value)
}

///|
test "docs: diff_repr can ignore tiny float changes" {
  let x = float_repr({ value: 1.0 })
  let y = float_repr({ value: 1.0 + 1.0e-13 })
  inspect(
    (
      pretty_print_delta(
        @diff.diff_repr(x, y, max_relative_error=0.0),
        compact_threshold=100,
        use_ansi=false,
      ),
      pretty_print_delta(
        @diff.diff_repr(x, y, max_relative_error=1.0e-12),
        compact_threshold=100,
        use_ansi=false,
      ),
    ),
    content="(\"-1 +1.0000000000001\", \"1\")",
  )
}
