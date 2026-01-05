///|
pub impl Debug for Int with debug(self) {
  Repr::int(self)
}

///|
pub impl Debug for Int16 with debug(self) {
  // Use an opaque wrapper to preserve the exact integer width.
  Repr::opaque_("Int16", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for Int64 with debug(self) {
  // Keep the explicit type tag (instead of printing `1L`) to make diffs clearer.
  Repr::opaque_("Int64", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for UInt16 with debug(self) {
  Repr::opaque_("UInt16", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for UInt with debug(self) {
  Repr::opaque_("UInt", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for UInt64 with debug(self) {
  Repr::opaque_("UInt64", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for Double with debug(self) {
  Repr::double(self)
}

///|
pub impl Debug for Float with debug(self) {
  // Preserve float width (instead of printing as Double).
  Repr::opaque_("Float", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for Bool with debug(self) {
  Repr::bool(self)
}

///|
pub impl Debug for Byte with debug(self) {
  // Use hex to make byte sequences easier to read.
  Repr::literal("0x" + self.to_hex())
}

///|
pub impl Debug for Char with debug(self) {
  Repr::char(self)
}

///|
pub impl Debug for String with debug(self) {
  Repr::string(self)
}

///|
pub impl Debug for StringView with debug(self) {
  Repr::opaque_("StringView", [Repr::string(self.to_string())])
}

///|
pub impl Debug for Bytes with debug(self) {
  Repr::opaque_("Bytes", [Repr::array(self.to_array().map(fn(b) { debug(b) }))])
}

///|
pub impl Debug for BytesView with debug(self) {
  Repr::opaque_("BytesView", [
    Repr::array(self.to_array().map(fn(b) { debug(b) })),
  ])
}

///|
pub impl Debug for Unit with debug(_) {
  Repr::tuple([])
}

///|
pub impl[T : Debug] Debug for Array[T] with debug(self) {
  Repr::array(self.map(fn(x) { debug(x) }))
}

///|
pub impl[T : Debug] Debug for ArrayView[T] with debug(self) {
  Repr::opaque_("ArrayView", [
    Repr::array(self.to_array().map(fn(x) { debug(x) })),
  ])
}

///|
pub impl[T : Debug] Debug for FixedArray[T] with debug(self) {
  // `FixedArray` can be viewed as `ArrayView` via slicing.
  let view : ArrayView[T] = self[:]
  Repr::opaque_("FixedArray", [
    Repr::array(view.to_array().map(fn(x) { debug(x) })),
  ])
}

///|
pub impl[T : Debug] Debug for ReadOnlyArray[T] with debug(self) {
  // `ReadOnlyArray` can be viewed as `ArrayView` via slicing.
  let view : ArrayView[T] = self[:]
  Repr::opaque_("ReadOnlyArray", [
    Repr::array(view.to_array().map(fn(x) { debug(x) })),
  ])
}

///|
pub impl[T : Debug] Debug for T? with debug(self) {
  match self {
    None => Repr::ctor("None", [])
    Some(x) => Repr::ctor("Some", [(None, debug(x))])
  }
}

///|
pub impl[T : Debug, E : Debug] Debug for Result[T, E] with debug(self) {
  match self {
    Ok(x) => Repr::ctor("Ok", [(None, debug(x))])
    Err(e) => Repr::ctor("Err", [(None, debug(e))])
  }
}

///|
pub impl[A : Debug] Debug for @list.List[A] with debug(self) {
  Repr::opaque_("List", [Repr::array(self.to_array().map(fn(x) { debug(x) }))])
}

///|
pub impl[K : Debug, V : Debug] Debug for @hashmap.HashMap[K, V] with debug(self) {
  // `HashMap` iteration order is unspecified; sort by key repr for stable output.
  let entries0 : Array[(Repr, Repr)] = self
    .to_array()
    .map(fn(kv) {
      let (k, v) = kv
      (debug(k), debug(v))
    })
  let entries : Array[(Repr, Repr)] = entries0
  entries.sort_by(fn(a, b) { a.0.compare(b.0) })
  Repr::opaque_("HashMap", [Repr::dict(entries)])
}

///|
pub impl[K : Debug] Debug for @hashset.HashSet[K] with debug(self) {
  // `HashSet` iteration order is unspecified; sort elements for stable output.
  let xs0 : Array[Repr] = self.to_array().map(fn(x) { debug(x) })
  let xs : Array[Repr] = xs0
  xs.sort_by(fn(a, b) { a.compare(b) })
  Repr::opaque_("HashSet", [Repr::array(xs)])
}

///|
pub impl[A : Debug] Debug for @deque.Deque[A] with debug(self) {
  Repr::opaque_("Deque", [Repr::array(self.to_array().map(fn(x) { debug(x) }))])
}

///|
pub impl[A : Debug] Debug for @queue.Queue[A] with debug(self) {
  // `Queue` doesn't expose `to_array`, but we can snapshot via `iter()`.
  Repr::opaque_("Queue", [
    Repr::array(self.iter().to_array().map(fn(x) { debug(x) })),
  ])
}

///|
pub impl[A] Debug for Iter[A] with debug(_) {
  // Avoid consuming the iterator (and avoid potentially infinite iterations).
  Repr::opaque_("Iter", [])
}

///|
pub impl[A] Debug for Iterator[A] with debug(_) {
  // Avoid consuming the iterator (and avoid potentially infinite iterations).
  Repr::opaque_("Iterator", [])
}

///|
pub impl[A, B] Debug for Iter2[A, B] with debug(_) {
  // Avoid consuming the iterator (and avoid potentially infinite iterations).
  Repr::opaque_("Iter2", [])
}

///|
pub impl[A, B] Debug for Iterator2[A, B] with debug(_) {
  // Avoid consuming the iterator (and avoid potentially infinite iterations).
  Repr::opaque_("Iterator2", [])
}

///|
pub impl[T : Debug] Debug for MutArrayView[T] with debug(self) {
  // Snapshot through an owned array to avoid aliasing surprises.
  Repr::opaque_("MutArrayView", [
    Repr::array(self[:].to_array().map(fn(x) { debug(x) })),
  ])
}

///|
pub impl[T : Debug] Debug for Ref[T] with debug(self) {
  Repr::opaque_("Ref", [debug(self.val)])
}

///|
pub impl[A : Debug + Compare] Debug for @priority_queue.PriorityQueue[A] with debug(
  self,
) {
  // `PriorityQueue` iteration order depends on internal heap state; sort for stable output.
  let xs0 : Array[Repr] = self.to_array().map(fn(x) { debug(x) })
  let xs : Array[Repr] = xs0
  xs.sort_by(fn(a, b) { a.compare(b) })
  Repr::opaque_("PriorityQueue", [Repr::array(xs)])
}

///|
pub impl Debug for @buffer.Buffer with debug(self) {
  // Represent buffer by its current bytes content.
  Repr::opaque_("Buffer", [debug(self.contents())])
}

///|
pub impl[A : Debug, B : Debug] Debug for (A, B) with debug(self) {
  let (a, b) = self
  Repr::tuple([debug(a), debug(b)])
}

///|
pub impl[A : Debug, B : Debug, C : Debug] Debug for (A, B, C) with debug(self) {
  let (a, b, c) = self
  Repr::tuple([debug(a), debug(b), debug(c)])
}

///|
pub impl[A : Debug, B : Debug, C : Debug, D : Debug] Debug for (A, B, C, D) with debug(
  self,
) {
  let (a, b, c, d) = self
  Repr::tuple([debug(a), debug(b), debug(c), debug(d)])
}

///|
pub impl[A : Debug, B : Debug, C : Debug, D : Debug, E : Debug] Debug for (
  A,
  B,
  C,
  D,
  E,
) with debug(self) {
  let (a, b, c, d, e) = self
  Repr::tuple([debug(a), debug(b), debug(c), debug(d), debug(e)])
}

///|
pub impl[A : Debug, B : Debug, C : Debug, D : Debug, E : Debug, F : Debug] Debug for (
  A,
  B,
  C,
  D,
  E,
  F,
) with debug(self) {
  let (a, b, c, d, e, f) = self
  Repr::tuple([debug(a), debug(b), debug(c), debug(d), debug(e), debug(f)])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
] Debug for (A, B, C, D, E, F, G) with debug(self) {
  let (a, b, c, d, e, f, g) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
] Debug for (A, B, C, D, E, F, G, H) with debug(self) {
  let (a, b, c, d, e, f, g, h) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
] Debug for (A, B, C, D, E, F, G, H, I) with debug(self) {
  let (a, b, c, d, e, f, g, h, i) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J) with debug(self) {
  let (a, b, c, d, e, f, g, h, i, j) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K) with debug(self) {
  let (a, b, c, d, e, f, g, h, i, j, k) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L) with debug(self) {
  let (a, b, c, d, e, f, g, h, i, j, k, l) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M) with debug(self) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N) with debug(self) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
  O : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) with debug(self) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
    debug(o),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
  O : Debug,
  P : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) with debug(self) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
    debug(o),
    debug(p),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
  O : Debug,
  P : Debug,
  Q : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) with debug(self) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
    debug(o),
    debug(p),
    debug(q),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
  O : Debug,
  P : Debug,
  Q : Debug,
  R : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) with debug(
  self,
) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
    debug(o),
    debug(p),
    debug(q),
    debug(r),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
  O : Debug,
  P : Debug,
  Q : Debug,
  R : Debug,
  S : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) with debug(
  self,
) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
    debug(o),
    debug(p),
    debug(q),
    debug(r),
    debug(s),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
  O : Debug,
  P : Debug,
  Q : Debug,
  R : Debug,
  S : Debug,
  T : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) with debug(
  self,
) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
    debug(o),
    debug(p),
    debug(q),
    debug(r),
    debug(s),
    debug(t),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
  O : Debug,
  P : Debug,
  Q : Debug,
  R : Debug,
  S : Debug,
  T : Debug,
  U : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) with debug(
  self,
) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
    debug(o),
    debug(p),
    debug(q),
    debug(r),
    debug(s),
    debug(t),
    debug(u),
  ])
}

///|
pub impl[
  A : Debug,
  B : Debug,
  C : Debug,
  D : Debug,
  E : Debug,
  F : Debug,
  G : Debug,
  H : Debug,
  I : Debug,
  J : Debug,
  K : Debug,
  L : Debug,
  M : Debug,
  N : Debug,
  O : Debug,
  P : Debug,
  Q : Debug,
  R : Debug,
  S : Debug,
  T : Debug,
  U : Debug,
  V : Debug,
] Debug for (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) with debug(
  self,
) {
  let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v) = self
  Repr::tuple([
    debug(a),
    debug(b),
    debug(c),
    debug(d),
    debug(e),
    debug(f),
    debug(g),
    debug(h),
    debug(i),
    debug(j),
    debug(k),
    debug(l),
    debug(m),
    debug(n),
    debug(o),
    debug(p),
    debug(q),
    debug(r),
    debug(s),
    debug(t),
    debug(u),
    debug(v),
  ])
}

///|
test "tuple Debug implementations" {
  // Test tuple2
  inspect(pretty_print((1, "a")), content="(1, \"a\")")

  // Test tuple3
  inspect(pretty_print((1, "a", true)), content="(1, \"a\", true)")

  // Test tuple4
  inspect(
    pretty_print((1, "a", true, 2.0)),
    content=(
      #|(1, "a", true, 2)
    ),
  )

  // Test tuple5
  inspect(
    pretty_print((1, "a", true, 2.0, 'c')),
    content=(
      #|(1, "a", true, 2, 'c')
    ),
  )

  // Test tuple6
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6)),
    content=(
      #|(1, "a", true, 2, 'c', 6)
    ),
  )

  // Test tuple7
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6, "g")),
    content=(
      #|(1, "a", true, 2, 'c', 6, "g")
    ),
  )

  // Test tuple8
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6, "g", false)),
    content=(
      #|(1, "a", true, 2, 'c', 6, "g", false)
    ),
  )

  // Test tuple9
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6, "g", false, 9)),
    content=(
      #|(1, "a", true, 2, 'c', 6, "g", false, 9)
    ),
  )

  // Test tuple10
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6, "g", false, 9, "j")),
    content=(
      #|(1, "a", true, 2, 'c', 6, "g", false, 9, "j")
    ),
  )

  // Test tuple11
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11)),
    content=(
      #|(1, "a", true, 2, 'c', 6, "g", false, 9, "j", 11)
    ),
  )

  // Test tuple12
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l")),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|)
    ),
  )

  // Test tuple13
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13)),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|)
    ),
  )

  // Test tuple14
  inspect(
    pretty_print(
      (1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n"),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|)
    ),
  )

  // Test tuple15
  inspect(
    pretty_print(
      (1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|  15,
      #|)
    ),
  )

  // Test tuple16
  inspect(
    pretty_print(
      (1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15, "p"),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|  15,
      #|  "p",
      #|)
    ),
  )

  // Test tuple17
  inspect(
    pretty_print(
      (
        1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15, "p",
        17,
      ),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|  15,
      #|  "p",
      #|  17,
      #|)
    ),
  )

  // Test tuple18
  inspect(
    pretty_print(
      (
        1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15, "p",
        17, "r",
      ),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|  15,
      #|  "p",
      #|  17,
      #|  "r",
      #|)
    ),
  )

  // Test tuple19
  inspect(
    pretty_print(
      (
        1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15, "p",
        17, "r", 19,
      ),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|  15,
      #|  "p",
      #|  17,
      #|  "r",
      #|  19,
      #|)
    ),
  )

  // Test tuple20
  inspect(
    pretty_print(
      (
        1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15, "p",
        17, "r", 19, "t",
      ),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|  15,
      #|  "p",
      #|  17,
      #|  "r",
      #|  19,
      #|  "t",
      #|)
    ),
  )

  // Test tuple21
  inspect(
    pretty_print(
      (
        1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15, "p",
        17, "r", 19, "t", 21,
      ),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|  15,
      #|  "p",
      #|  17,
      #|  "r",
      #|  19,
      #|  "t",
      #|  21,
      #|)
    ),
  )

  // Test tuple22
  inspect(
    pretty_print(
      (
        1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15, "p",
        17, "r", 19, "t", 21, "v",
      ),
    ),
    content=(
      #|(
      #|  1,
      #|  "a",
      #|  true,
      #|  2,
      #|  'c',
      #|  6,
      #|  "g",
      #|  false,
      #|  9,
      #|  "j",
      #|  11,
      #|  "l",
      #|  13,
      #|  "n",
      #|  15,
      #|  "p",
      #|  17,
      #|  "r",
      #|  19,
      #|  "t",
      #|  21,
      #|  "v",
      #|)
    ),
  )
}

///|
test "core data structures Debug implementations" {
  inspect(pretty_print((1 : Int16)), content="<Int16: 1>")
  inspect(pretty_print((1 : UInt16)), content="<UInt16: 1>")
  inspect(pretty_print((1 : UInt64)), content="<UInt64: 1>")
  inspect(pretty_print((1.0 : Float)), content="<Float: 1>")
  let b : Bytes = b"ab"
  inspect(
    pretty_print(b, compact_threshold=100, use_ansi=false),
    content="<Bytes: [0x61, 0x62]>",
  )
  let bv : BytesView = b[:]
  inspect(
    pretty_print(bv, compact_threshold=100, use_ansi=false),
    content="<BytesView: [0x61, 0x62]>",
  )
  let sv : StringView = "abc"[:]
  inspect(
    pretty_print(sv, compact_threshold=100, use_ansi=false),
    content="<StringView: \"abc\">",
  )
  let av : ArrayView[Int] = [1, 2, 3][1:3]
  inspect(
    pretty_print(av, compact_threshold=100, use_ansi=false),
    content="<ArrayView: [2, 3]>",
  )
  let fa : FixedArray[Int] = [1, 2, 3]
  inspect(
    pretty_print(fa, compact_threshold=100, use_ansi=false),
    content="<FixedArray: [1, 2, 3]>",
  )
  let ro : ReadOnlyArray[Int] = [1, 2, 3]
  inspect(
    pretty_print(ro, compact_threshold=100, use_ansi=false),
    content="<ReadOnlyArray: [1, 2, 3]>",
  )
  let lst : @list.List[Int] = @list.from_array([1, 2, 3])
  inspect(
    pretty_print(lst, compact_threshold=100, use_ansi=false),
    content="<List: [1, 2, 3]>",
  )
  let hm : @hashmap.HashMap[Int, String] = @hashmap.from_array([
    (2, "b"),
    (1, "a"),
  ])
  inspect(
    pretty_print(hm, compact_threshold=100, use_ansi=false),
    content=(
      #|<HashMap: { 1: "a", 2: "b" }>
    ),
  )
  let hs : @hashset.HashSet[Int] = @hashset.from_array([3, 1, 2])
  inspect(
    pretty_print(hs, compact_threshold=100, use_ansi=false),
    content="<HashSet: [1, 2, 3]>",
  )
  let dq : @deque.Deque[Int] = @deque.from_array([1, 2, 3])
  inspect(
    pretty_print(dq, compact_threshold=100, use_ansi=false),
    content="<Deque: [1, 2, 3]>",
  )
  let q : @queue.Queue[Int] = @queue.from_array([1, 2, 3])
  inspect(
    pretty_print(q, compact_threshold=100, use_ansi=false),
    content="<Queue: [1, 2, 3]>",
  )
  let pq : @priority_queue.PriorityQueue[Int] = @priority_queue.from_array([
    3, 1, 2,
  ])
  inspect(
    pretty_print(pq, compact_threshold=100, use_ansi=false),
    content="<PriorityQueue: [1, 2, 3]>",
  )
  let buf = @buffer.new()
  buf.write_bytes(b"ab")
  inspect(
    pretty_print(buf, compact_threshold=100, use_ansi=false),
    content="<Buffer: <Bytes: [0x61, 0x62]>>",
  )
  let r : Ref[Int] = @ref.new(1)
  inspect(
    pretty_print(r, compact_threshold=100, use_ansi=false),
    content="<Ref: 1>",
  )
  let mv : MutArrayView[Int] = [1, 2, 3].mut_view(start=1, end=3)
  inspect(
    pretty_print(mv, compact_threshold=100, use_ansi=false),
    content="<MutArrayView: [2, 3]>",
  )
  inspect(pretty_print((Ok(1) : Result[Int, String])), content="Ok(1)")
  inspect(pretty_print((Err("e") : Result[Int, String])), content="Err(\"e\")")
}

///|
pub impl[K : Debug, V : Debug] Debug for Map[K, V] with debug(self) {
  Repr::dict(
    self
    .to_array()
    .map(fn(kv) {
      let (k, v) = kv
      (debug(k), debug(v))
    }),
  )
}

///|
pub impl Debug for SourceLoc with debug(self) {
  Repr::opaque_("SourceLoc", [Repr::string(self.to_string())])
}
