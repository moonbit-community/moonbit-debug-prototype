///|
/// Deprecated low-level `Repr` constructors (partial nodes).

///|
#deprecated(skip_current_package=true)
fn Repr::field(name : String, value : Repr) -> Repr {
  RecordField(name, value)
}

///|
#deprecated(skip_current_package=true)
fn Repr::labeled(label : String, value : Repr) -> Repr {
  EnumLabeledArg(label, value)
}

///|
#deprecated(skip_current_package=true)
fn Repr::entry(key : Repr, value : Repr) -> Repr {
  MapEntry(key, value)
}
