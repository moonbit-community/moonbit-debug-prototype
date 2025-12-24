///|
test "process finds #debug.derive on struct" {
  let source =
    #|#debug.derive
    #|struct Point {
    #|  x : Int
    #|  y : Int
    #|}
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  let result = buf.to_string()
  assert_true(result.contains("impl @debug.Debug for Point"))
  assert_true(result.contains("fields[\"x\"]"))
  assert_true(result.contains("fields[\"y\"]"))
}

///|
test "process ignores types without #debug.derive" {
  let source =
    #|struct Person {
    #|  name : String
    #|  age : Int
    #|}
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  assert_eq(buf.to_string(), "")
}

///|
test "generate_debug_impl for Record" {
  let source =
    #|#debug.derive
    #|struct Point {
    #|  x : Int
    #|  y : Int
    #|}
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl @debug.Debug for Point with debug(self) {
      #|  let fields : Map[String, @repr.Repr] = {}
      #|  fields["x"] = @debug.debug(self.x)
      #|  fields["y"] = @debug.debug(self.y)
      #|  @repr.Repr::record(fields)
      #|}
      #|
      #|
    ),
  )
}

///|
test "generate_debug_impl for Variant (enum)" {
  let source =
    #|#debug.derive
    #|enum Color {
    #|  Red
    #|  Green
    #|  Blue
    #|  Rgb(Int, Int, Int)
    #|}
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl @debug.Debug for Color with debug(self) {
      #|  match self {
      #|    Red => @repr.Repr::ctor("Red", [])
      #|    Green => @repr.Repr::ctor("Green", [])
      #|    Blue => @repr.Repr::ctor("Blue", [])
      #|    Rgb(x0, x1, x2) => @repr.Repr::ctor("Rgb", [(None, @debug.debug(x0)), (None, @debug.debug(x1)), (None, @debug.debug(x2))])
      #|  }
      #|}
      #|
      #|
    ),
  )
}

///|
test "generate_debug_impl for enum with labeled args" {
  let source =
    #|#debug.derive
    #|enum Shape {
    #|  Circle(radius~ : Double)
    #|  Rectangle(width~ : Double, height~ : Double)
    #|}
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl @debug.Debug for Shape with debug(self) {
      #|  match self {
      #|    Circle(radius~) => @repr.Repr::ctor("Circle", [(Some("radius"), @debug.debug(radius))])
      #|    Rectangle(width~, height~) => @repr.Repr::ctor("Rectangle", [(Some("width"), @debug.debug(width)), (Some("height"), @debug.debug(height))])
      #|  }
      #|}
      #|
      #|
    ),
  )
}

///|
test "generate_debug_impl for TupleStruct" {
  let source =
    #|#debug.derive
    #|struct Meters(Int)
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl @debug.Debug for Meters with debug(self) {
      #|  match self {
      #|    Meters(x0) => @repr.Repr::ctor("Meters", [(None, @debug.debug(x0))])
      #|  }
      #|}
      #|
      #|
    ),
  )
}

///|
test "generate_debug_impl for generic struct" {
  let source =
    #|#debug.derive
    #|struct Pair[A, B] {
    #|  first : A
    #|  second : B
    #|}
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl[A : @debug.Debug, B : @debug.Debug] @debug.Debug for Pair[A, B] with debug(self) {
      #|  let fields : Map[String, @repr.Repr] = {}
      #|  fields["first"] = @debug.debug(self.first)
      #|  fields["second"] = @debug.debug(self.second)
      #|  @repr.Repr::record(fields)
      #|}
      #|
      #|
    ),
  )
}

///|
test "generate_debug_impl for generic enum" {
  let source =
    #|#debug.derive
    #|enum Option[T] {
    #|  None
    #|  Some(T)
    #|}
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl[T : @debug.Debug] @debug.Debug for Option[T] with debug(self) {
      #|  match self {
      #|    None => @repr.Repr::ctor("None", [])
      #|    Some(x0) => @repr.Repr::ctor("Some", [(None, @debug.debug(x0))])
      #|  }
      #|}
      #|
      #|
    ),
  )
}

///|
test "generate_debug_impl for Newtype" {
  let source =
    #|#debug.derive
    #|struct UserId(Int)
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl @debug.Debug for UserId with debug(self) {
      #|  match self {
      #|    UserId(x0) => @repr.Repr::ctor("UserId", [(None, @debug.debug(x0))])
      #|  }
      #|}
      #|
      #|
    ),
  )
}

///|
test "process multiple types in one file" {
  let source =
    #|#debug.derive
    #|struct Point { x : Int; y : Int }
    #|
    #|struct NotDerived { a : Int }
    #|
    #|#debug.derive
    #|enum Status { Active; Inactive }
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  let result = buf.to_string()
  // Should have Point
  assert_true(result.contains("impl @debug.Debug for Point"))
  // Should have Status
  assert_true(result.contains("impl @debug.Debug for Status"))
  // Should NOT have NotDerived
  assert_false(result.contains("NotDerived"))
}

///|
test "is_debug_derive_attr recognizes correct attribute" {
  let source =
    #|#debug.derive
    #|struct Foo { x : Int }
  let (impls, _) = @parser.parse_string(source)
  let has_derive = impls.any(fn(item) {
    match item {
      TopTypeDef(decl) => has_debug_derive(decl)
      _ => false
    }
  })
  assert_true(has_derive)
}

///|
test "is_debug_derive_attr rejects other attributes" {
  let source =
    #|#other.attr
    #|struct Foo { x : Int }
  let (impls, _) = @parser.parse_string(source)
  let has_derive = impls.any(fn(item) {
    match item {
      TopTypeDef(decl) => has_debug_derive(decl)
      _ => false
    }
  })
  assert_false(has_derive)
}

///|
test "generate_debug_impl for suberror NoPayload" {
  let source =
    #|#debug.derive
    #|suberror SimpleError
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl @debug.Debug for SimpleError with debug(self) {
      #|  @repr.Repr::ctor("SimpleError", [])
      #|}
      #|
      #|
    ),
  )
}

///|
test "generate_debug_impl for suberror SinglePayload" {
  let source =
    #|#debug.derive
    #|suberror ValueError String
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl @debug.Debug for ValueError with debug(self) {
      #|  match self {
      #|    ValueError(x0) => @repr.Repr::ctor("ValueError", [(None, @debug.debug(x0))])
      #|  }
      #|}
      #|
      #|
    ),
  )
}

///|
test "generate_debug_impl for suberror EnumPayload" {
  let source =
    #|#debug.derive
    #|suberror ParseError {
    #|  InvalidChar(Char)
    #|  UnexpectedEof
    #|}
  let (impls, _) = @parser.parse_string(source)
  let buf = StringBuilder::new()
  impls.each(fn(x) { process(x, buf) })
  inspect(
    buf.to_string(),
    content=(
      #|///|
      #|impl @debug.Debug for ParseError with debug(self) {
      #|  match self {
      #|    InvalidChar(x0) => @repr.Repr::ctor("InvalidChar", [(None, @debug.debug(x0))])
      #|    UnexpectedEof => @repr.Repr::ctor("UnexpectedEof", [])
      #|  }
      #|}
      #|
      #|
    ),
  )
}
