///|
fn main {
  // Skip the first two args (node path and script path)
  let all_args = @env.args()
  println(all_args)
  guard all_args is [_, input, output, ..] else {
    println("Error: expecting input and output file.")
    return
  }
  let (impls, diag) = try! @parser.parse_file(input)
  guard diag is [] else {
    println("Error: input file \{input} contains syntax error.")
    return
  }
  let buf = StringBuilder::new()
  buf.write_string("// generated file, do not edit\n")
  impls.each(fn(x) { process(x, buf) })
  println("auto_derive: \{input} -> \{output}")
  try! @fs.write_string_to_file(output, buf.to_string())
}

///|
/// Check if an attribute is a `#debug.derive` attribute
fn is_debug_derive_attr(attr : @attribute.Attribute) -> Bool {
  attr.raw == "#debug.derive"
}

///|
/// Check if a TypeDecl has the `#debug.derive` attribute
fn has_debug_derive(decl : @syntax.TypeDecl) -> Bool {
  decl.attrs.any(is_debug_derive_attr)
}

///|
/// Process a top-level item, if it's a TypeDef with #debug.derive, generate Debug impl
fn process(top : @syntax.Impl, buf : StringBuilder) -> Unit {
  match top {
    TopTypeDef(decl) =>
      if has_debug_derive(decl) {
        generate_debug_impl(decl, buf)
      }
    _ => ()
  }
}

///|
/// Generate visibility prefix based on TypeDecl visibility
/// pub(all) or pub types should generate "pub impl", otherwise "impl"
fn generate_visibility_prefix(decl : @syntax.TypeDecl) -> String {
  match decl.type_vis {
    Pub(_) => "pub "
    Default | Priv(_) => ""
  }
}

///|
/// Generate Debug trait implementation code for a TypeDecl
fn generate_debug_impl(decl : @syntax.TypeDecl, buf : StringBuilder) -> Unit {
  let type_name = decl.tycon
  let type_params = generate_type_params(decl)
  let type_constraints = generate_type_constraints(decl)
  let body = generate_debug_body(type_name, decl.components)
  let full_type = if type_params.is_empty() {
    type_name
  } else {
    "\{type_name}[\{type_params}]"
  }
  // Generate visibility prefix based on type visibility
  let vis_prefix = generate_visibility_prefix(decl)
  // Generate the impl block
  let impl_header = if type_constraints.is_empty() {
    "\{vis_prefix}impl @debug.Debug for \{full_type} with debug(self)"
  } else {
    "\{vis_prefix}impl[\{type_constraints}] @debug.Debug for \{full_type} with debug(self)"
  }
  buf.write_string("///|\n\{impl_header} {\n\{body}\n}\n\n")
}

///|
/// Generate type parameters string (e.g., "T, U")
fn generate_type_params(decl : @syntax.TypeDecl) -> String {
  decl.params
  .map(fn(p) {
    match p.name {
      Some(name) => name
      None => "_"
    }
  })
  .to_array()
  .join(", ")
}

///|
/// Generate type constraints string (e.g., "T : @debug.Debug, U : @debug.Debug")
fn generate_type_constraints(decl : @syntax.TypeDecl) -> String {
  decl.params
  .filter_map(fn(p) {
    match p.name {
      Some(name) => Some("\{name} : @debug.Debug")
      None => None
    }
  })
  .to_array()
  .join(", ")
}

///|
/// Generate the debug method body based on TypeDesc
fn generate_debug_body(type_name : String, desc : @syntax.TypeDesc) -> String {
  match desc {
    Abstract | Extern | Alias(_) =>
      // For abstract, extern, and alias types, just return the type name as literal
      "  @repr.Repr::literal(\"\{type_name}\")"
    Newtype(inner_type) => generate_newtype_body(type_name, inner_type)
    Variant(constrs) => generate_variant_body(type_name, constrs)
    Record(fields) => generate_record_body(type_name, fields)
    TupleStruct(types) => generate_tuple_struct_body(type_name, types)
    Error(exception_decl) => generate_error_body(type_name, exception_decl)
  }
}

///|
/// Generate debug body for Newtype
fn generate_newtype_body(type_name : String, _inner : @syntax.Type) -> String {
  // Newtype: struct TypeName(InnerType)
  // Pattern: TypeName(inner) => Repr::ctor("TypeName", [(None, debug(inner))])
  let buf = StringBuilder::new()
  buf.write_string("  match self {\n")
  buf.write_string(
    "    \{type_name}(inner) => @repr.Repr::ctor(\"\{type_name}\", [(None, @debug.debug(inner))])\n",
  )
  buf.write_string("  }")
  buf.to_string()
}

///|
/// Generate debug body for Variant (enum)
fn generate_variant_body(
  _type_name : String,
  constrs : @list.List[@syntax.ConstrDecl],
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("  match self {\n")
  constrs.each(fn(constr) {
    let constr_name = constr.name.name
    match constr.args {
      None =>
        // Enum variant with no arguments: Ctor => Repr::ctor("Ctor", [])
        buf.write_string(
          "    \{constr_name} => @repr.Repr::ctor(\"\{constr_name}\", [])\n",
        )
      Some(args) => {
        let arg_list = args.to_array()
        if arg_list.is_empty() {
          buf.write_string(
            "    \{constr_name} => @repr.Repr::ctor(\"\{constr_name}\", [])\n",
          )
        } else {
          // Generate pattern and repr construction
          let (pattern, repr_args) = generate_constr_pattern_and_args(arg_list)
          buf.write_string(
            "    \{constr_name}(\{pattern}) => @repr.Repr::ctor(\"\{constr_name}\", [\{repr_args}])\n",
          )
        }
      }
    }
  })
  buf.write_string("  }")
  buf.to_string()
}

///|
/// Generate pattern matching and Repr args for constructor arguments
fn generate_constr_pattern_and_args(
  args : Array[@syntax.ConstrParam],
) -> (String, String) {
  let patterns : Array[String] = []
  let repr_args : Array[String] = []
  for i, arg in args {
    match arg.label {
      Some(label) => {
        // Labeled argument: label~ pattern
        let var_name = label.name
        patterns.push("\{var_name}~")
        repr_args.push("(Some(\"\{var_name}\"), @debug.debug(\{var_name}))")
      }
      None => {
        // Positional argument: x0, x1, ...
        let var_name = "x\{i}"
        patterns.push(var_name)
        repr_args.push("(None, @debug.debug(\{var_name}))")
      }
    }
  }
  (patterns.join(", "), repr_args.join(", "))
}

///|
/// Generate debug body for Record (struct with named fields)
fn generate_record_body(
  _type_name : String,
  fields : @list.List[@syntax.FieldDecl],
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("  let fields : Map[String, @repr.Repr] = {}\n")
  fields.each(fn(field) {
    let field_name = field.name.label
    buf.write_string(
      "  fields[\"\{field_name}\"] = @debug.debug(self.\{field_name})\n",
    )
  })
  buf.write_string("  @repr.Repr::record(fields)")
  buf.to_string()
}

///|
/// Generate debug body for TupleStruct
fn generate_tuple_struct_body(
  type_name : String,
  types : @list.List[@syntax.Type],
) -> String {
  let buf = StringBuilder::new()
  let type_count = types.length()
  if type_count == 0 {
    buf.write_string("  @repr.Repr::ctor(\"\{type_name}\", [])")
  } else {
    // Generate pattern: TypeName(x0, x1, ...)
    let vars : Array[String] = []
    let repr_args : Array[String] = []
    for i = 0; i < type_count; i = i + 1 {
      let var_name = "x\{i}"
      vars.push(var_name)
      repr_args.push("(None, @debug.debug(\{var_name}))")
    }
    let pattern = vars.join(", ")
    let args_str = repr_args.join(", ")
    buf.write_string("  match self {\n")
    buf.write_string(
      "    \{type_name}(\{pattern}) => @repr.Repr::ctor(\"\{type_name}\", [\{args_str}])\n",
    )
    buf.write_string("  }")
  }
  buf.to_string()
}

///|
/// Generate debug body for Error (suberror types)
fn generate_error_body(
  type_name : String,
  exception_decl : @syntax.ExceptionDecl,
) -> String {
  match exception_decl {
    NoPayload =>
      // suberror MyError - no payload
      "  @repr.Repr::ctor(\"\{type_name}\", [])"
    SinglePayload(_) => {
      // suberror MyError Type - single payload
      let buf = StringBuilder::new()
      buf.write_string("  match self {\n")
      buf.write_string(
        "    \{type_name}(x0) => @repr.Repr::ctor(\"\{type_name}\", [(None, @debug.debug(x0))])\n",
      )
      buf.write_string("  }")
      buf.to_string()
    }
    EnumPayload(constrs) =>
      // suberror MyError { Variant1; Variant2(Int) } - enum-like payload
      generate_variant_body(type_name, constrs)
  }
}
