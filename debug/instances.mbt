///|
pub impl Debug for Int with debug(self) {
  Repr::int(self)
}

///|
pub impl Debug for Int64 with debug(self) {
  Repr::opaque_("Int64", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for UInt with debug(self) {
  Repr::opaque_("UInt", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for Double with debug(self) {
  Repr::double(self)
}

///|
pub impl Debug for Bool with debug(self) {
  Repr::bool(self)
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
pub impl Debug for Unit with debug(_) {
  Repr::tuple([])
}

///|
pub impl[T : Debug] Debug for Array[T] with debug(self) {
  Repr::array(self.map(fn(x) { debug(x) }))
}

///|
pub impl[T : Debug] Debug for T? with debug(self) {
  match self {
    None => Repr::ctor("None", [])
    Some(x) => Repr::ctor("Some", [(None, debug(x))])
  }
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
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l")
    ),
  )

  // Test tuple13
  inspect(
    pretty_print((1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13)),
    content=(
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13)
    ),
  )

  // Test tuple14
  inspect(
    pretty_print(
      (1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n"),
    ),
    content=(
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n")
    ),
  )

  // Test tuple15
  inspect(
    pretty_print(
      (1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15),
    ),
    content=(
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n",
      #| 15)
    ),
  )

  // Test tuple16
  inspect(
    pretty_print(
      (1, "a", true, 2.0, 'c', 6, "g", false, 9, "j", 11, "l", 13, "n", 15, "p"),
    ),
    content=(
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n",
      #| 15,
      #| "p")
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
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n",
      #| 15,
      #| "p",
      #| 17)
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
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n",
      #| 15,
      #| "p",
      #| 17,
      #| "r")
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
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n",
      #| 15,
      #| "p",
      #| 17,
      #| "r",
      #| 19)
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
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n",
      #| 15,
      #| "p",
      #| 17,
      #| "r",
      #| 19,
      #| "t")
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
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n",
      #| 15,
      #| "p",
      #| 17,
      #| "r",
      #| 19,
      #| "t",
      #| 21)
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
      #|(1,
      #| "a",
      #| true,
      #| 2,
      #| 'c',
      #| 6,
      #| "g",
      #| false,
      #| 9,
      #| "j",
      #| 11,
      #| "l",
      #| 13,
      #| "n",
      #| 15,
      #| "p",
      #| 17,
      #| "r",
      #| 19,
      #| "t",
      #| 21,
      #| "v")
    ),
  )
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
