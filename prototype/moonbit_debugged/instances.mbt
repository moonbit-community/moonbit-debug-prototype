///|
pub impl Debug for Int with debug(self) {
  int(self)
}

///|
pub impl Debug for Int64 with debug(self) {
  opaque_literal("Int64", repr(self))
}

///|
pub impl Debug for UInt with debug(self) {
  opaque_literal("UInt", repr(self))
}

///|
pub impl Debug for Double with debug(self) {
  double(self)
}

///|
pub impl Debug for Bool with debug(self) {
  bool(self)
}

///|
pub impl Debug for Char with debug(self) {
  char(self)
}

///|
pub impl Debug for String with debug(self) {
  string(self)
}

///|
pub impl[T : Debug] Debug for Array[T] with debug(self) {
  array(self.map(fn(x) { debug(x) }))
}

///|
pub impl[T : Debug] Debug for T? with debug(self) {
  match self {
    None => ctor("None", [])
    Some(x) => ctor("Some", [debug(x)])
  }
}

///|
pub impl[A : Debug, B : Debug] Debug for (A, B) with debug(self) {
  let (a, b) = self
  ctor("Tuple", [debug(a), debug(b)])
}

///|
pub impl[K : Debug, V : Debug] Debug for Map[K, V] with debug(self) {
  assoc(
    "Map",
    self
    .to_array()
    .map(fn(kv) {
      let (k, v) = kv
      (debug(k), debug(v))
    }),
  )
}
