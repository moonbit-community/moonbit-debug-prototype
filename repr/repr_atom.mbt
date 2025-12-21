///|
/// Smart constructors for `Repr` (constructible outside the package).

///|
/// Construct an `Int16Lit` leaf.
pub fn Repr::int16(x : Int16) -> Repr {
  Int16Lit(x)
}

///|
/// Construct an `IntLit` leaf.
pub fn Repr::int(x : Int) -> Repr {
  IntLit(x)
}

///|
/// Construct an `Int64Lit` leaf.
pub fn Repr::int64(x : Int64) -> Repr {
  Int64Lit(x)
}

///|
/// Construct a `UInt16Lit` leaf.
pub fn Repr::uint16(x : UInt16) -> Repr {
  UInt16Lit(x)
}

///|
/// Construct a `UIntLit` leaf.
pub fn Repr::uint(x : UInt) -> Repr {
  UIntLit(x)
}

///|
/// Construct a `UInt64Lit` leaf.
pub fn Repr::uint64(x : UInt64) -> Repr {
  UInt64Lit(x)
}

///|
/// Construct a `DoubleLit` leaf.
pub fn Repr::double(x : Double) -> Repr {
  DoubleLit(x)
}

///|
/// Construct a `FloatLit` leaf.
pub fn Repr::float(x : Float) -> Repr {
  FloatLit(x)
}

///|
/// Construct a `BigIntLit` leaf.
pub fn Repr::bigint(x : BigInt) -> Repr {
  BigIntLit(x)
}

///|
/// Construct a `BoolLit` leaf.
pub fn Repr::bool(x : Bool) -> Repr {
  BoolLit(x)
}

///|
/// Construct a `CharLit` leaf.
pub fn Repr::char(x : Char) -> Repr {
  CharLit(x)
}

///|
/// Construct a `StringLit` leaf.
pub fn Repr::string(x : String) -> Repr {
  StringLit(x)
}

///|
/// Construct a `Tuple` node from pre-built child `Repr`s.
pub fn Repr::tuple(children : Array[Repr]) -> Repr {
  Tuple(children)
}

///|
/// Construct an `Array` node from pre-built child `Repr`s.
pub fn Repr::array(children : Array[Repr]) -> Repr {
  Array(children)
}

///|
/// Construct a `Record` node from pre-built child `Repr`s.
pub fn Repr::record(fields : Map[String, Repr]) -> Repr {
  Record(fields.to_array().map(fn(p) { Repr::field(p.0, p.1) }))
}

///|
/// Construct an `Opaque(name, children)` node.
///
/// This is useful for values where you want to keep a tag/type name but still
/// show a structural summary through children (e.g. `<Map: {...}>`).
pub fn Repr::opaque_(name : String, children : Array[Repr]) -> Repr {
  Opaque(name, children)
}

///|
/// Construct a `Literal(value)` leaf (already formatted).
pub fn Repr::literal(value : String) -> Repr {
  Literal(value)
}

///|
/// Construct a `Map` node from key/value `Repr` pairs (for map literals).
pub fn Repr::dict(contents : Array[(Repr, Repr)]) -> Repr {
  Map(
    contents.map(fn(pair) {
      let (k, v) = pair
      Repr::entry(k, v)
    }),
  )
}

///|
/// Construct an `Omitted` marker node.
pub fn Repr::omitted() -> Repr {
  Omitted
}
