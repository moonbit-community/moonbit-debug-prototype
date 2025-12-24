// generated file, do not edit
///|
impl @debug.Debug for Pos with debug(self) {
  let fields : Map[String, @repr.Repr] = {}
  fields["x"] = @debug.debug(self.x)
  fields["y"] = @debug.debug(self.y)
  fields["z"] = @debug.debug(self.z)
  @repr.Repr::record(fields)
}

///|
pub impl @debug.Debug for PubPoint with debug(self) {
  let fields : Map[String, @repr.Repr] = {}
  fields["x"] = @debug.debug(self.x)
  fields["y"] = @debug.debug(self.y)
  @repr.Repr::record(fields)
}

///|
pub impl @debug.Debug for PubAllPoint with debug(self) {
  let fields : Map[String, @repr.Repr] = {}
  fields["x"] = @debug.debug(self.x)
  fields["y"] = @debug.debug(self.y)
  @repr.Repr::record(fields)
}

///|
impl @debug.Debug for Lambda with debug(self) {
  match self {
    Var(x0) => @repr.Repr::ctor("Var", [(None, @debug.debug(x0))])
    Lam(x0, ty~, x2) => @repr.Repr::ctor("Lam", [(None, @debug.debug(x0)), (Some("ty"), @debug.debug(ty)), (None, @debug.debug(x2))])
    App(x0, x1) => @repr.Repr::ctor("App", [(None, @debug.debug(x0)), (None, @debug.debug(x1))])
  }
}

///|
impl @debug.Debug for Pair with debug(self) {
  match self {
    Pair(x0, x1) => @repr.Repr::ctor("Pair", [(None, @debug.debug(x0)), (None, @debug.debug(x1))])
  }
}

///|
impl @debug.Debug for KeyNotFound with debug(self) {
  match self {
    KeyNotFound(x0) => @repr.Repr::ctor("KeyNotFound", [(None, @debug.debug(x0))])
  }
}

///|
impl[T : @debug.Debug] @debug.Debug for Stack[T] with debug(self) {
  let fields : Map[String, @repr.Repr] = {}
  fields["array"] = @debug.debug(self.array)
  fields["current"] = @debug.debug(self.current)
  @repr.Repr::record(fields)
}

