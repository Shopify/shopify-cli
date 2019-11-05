import { writeFileSync } from "fs";

import { Transform } from "assemblyscript/cli/transform";

import {
  Parser,
  Module,
  DeclaredElement,
  ExportsWalker,
  NodeKind,
  SourceKind,
  LiteralKind,
  Expression,
  CallExpression,
  LiteralExpression,
  ObjectLiteralExpression,
  PropertyAccessExpression,
  ArrayLiteralExpression,
  IntegerLiteralExpression,
  FloatLiteralExpression,
  StringLiteralExpression,
  FunctionDeclaration,
  VariableLikeDeclarationStatement,
  Type,
  TypeKind,
  TypeFlags,
  Program,
  Element,
  ElementKind,
  Global,
  Enum,
  EnumValue,
  Field,
  Function,
  FunctionPrototype,
  Class,
  ClassPrototype,
  Namespace,
  ConstantValueKind,
  Interface,
  Property,
  PropertyPrototype,
  File
} from "assemblyscript";

class GraphQLSchemaBuilder extends ExportsWalker {
  static build(program: Program): string {
    let builder = new GraphQLSchemaBuilder(program);
    builder.walk();
    const inputTypes = Array.from(builder.inputTypes, ([name, body]: [string, string]) => {
      return "input " + name + " {\n" + body + "\n}\n";
    });
    const outputTypes = Array.from(builder.outputTypes, ([name, body]: [string, string]) => {
      return "type " + name + " {\n" + body + "\n}\n";
    });
    return outputTypes.join("\n") + "\n\n" + inputTypes.join("\n") + "\n\ntype Query {\n" + builder.entrypoints.join("\n") + "\n}\n";
  }

  private inputTypes: Map<string, string> = new Map();
  private outputTypes: Map<string, string> = new Map();
  private entrypoints: string[] = [];

  constructor(program: Program, includePrivate: boolean = false) {
    super(program, includePrivate);
  }

  visitFunction(name: string, element: Function): void {
    if(name.startsWith("__")) { return; }
    if(name == "shopify_runtime_allocate") { return; }

    const args = element.signature.parameterTypes.map((paramType, i) => {
      const paramName = element.signature.getParameterName(i);
      const initializer = (<FunctionDeclaration>element.declaration).signature.parameters[i].initializer;
      return paramName + ": " + this.visitType(paramType, "Input", this.inputTypes, paramName == "configuration") + this.defaultValueAssignment(null, initializer);
    });
    this.entrypoints.push("\t" + name + "(" + args.join(", ") + "): " + this.visitType(element.signature.returnType, "Output", this.outputTypes, false));
  }

  visitGlobal(name: string, element: Global): void { }

  visitEnum(name: string, element: Enum): void { }

  visitClass(name: string, element: Class): void { }

  visitInterface(name: string, element: Interface): void { }

  visitField(name: string, element: Field): void { }

  visitNamespace(name: string, element: Namespace): void { }

  visitAlias(name: string, element: Element, originalName: string): void { }

  private visitClassReference(klass: Class, prefix: string, types: Map<string, string>, inferDefaultValues: boolean): string {
    return Array.from(klass.members || [], ([name, fieldel]: [String, DeclaredElement]) => {
      const field = <Field>fieldel;
      if(field.memoryOffset < 0 || !field.type) {
        return null;
      } else {
        const initializer = (<VariableLikeDeclarationStatement>field.declaration).initializer;
        return "\t" + name + ": " + this.visitType(field.type, prefix, types, inferDefaultValues) + this.defaultValueAssignment(inferDefaultValues ? field.type : null, initializer);
      }
    }).filter((fld: string|null) => !!fld).join("\n");
  }

  private visitType(type: Type, prefix: string, types: Map<string, string>, inferDefaultValues: boolean): string {
    if(type.isManaged) {
      throw "cannot use managed type " + type + " in interface";
    }

    let ref = this.visitAsIfNullable(type, prefix, types, inferDefaultValues);
    if(!type.is(TypeFlags.NULLABLE)) { ref += "!"; }

    return ref;
  }

  private visitAsIfNullable(type: Type, prefix: string, types: Map<string, string>, inferDefaultValues: boolean): string {
    if(type.is(TypeFlags.REFERENCE) && type.classReference) {
      let sliceType = this.sliceType(type.classReference);

      if(sliceType) {
        if(type.classReference.prototype.declaration.name.text == "Str") { return "String"; }
        return "[" + this.visitType(sliceType, prefix, types, inferDefaultValues) + "]";
      } else {
        const name = prefix + this.internalNameToGraphQL(type.classReference.internalName);

        if(!types.has(name)) {
          types.set(name, this.visitClassReference(type.classReference, prefix, types, inferDefaultValues));
        }

        return name;
      }
    } else {
      switch (type.kind) {
        case TypeKind.I32: return "Int";
        case TypeKind.U64: return "ID";
        case TypeKind.BOOL: return "Boolean";
        case TypeKind.F64: return "Float";
        default:
          throw "cannot use primitive type " + type + " in interface";
    }

    }
  }

  private defaultValueAssignment(type: Type|null, expr: Expression|null): string {
    const value = this.defaultValue(type, expr);
    if(value) { return " = " + value; }
    return "";
  }

  private defaultValue(type: Type|null, expr: Expression|null): string|null {
    if(expr) {
      if(expr.kind == NodeKind.LITERAL && (<LiteralExpression>expr).literalKind == LiteralKind.INTEGER) {
        return "" + (<IntegerLiteralExpression>expr).value;
      }

      if(expr.kind == NodeKind.LITERAL && (<LiteralExpression>expr).literalKind == LiteralKind.FLOAT) {
        return "" + (<FloatLiteralExpression>expr).value;
      }

      if(expr.kind == NodeKind.LITERAL && (<LiteralExpression>expr).literalKind == LiteralKind.STRING) {
        return JSON.stringify((<StringLiteralExpression>expr).value);
      }

      if(expr.kind == NodeKind.LITERAL && (<LiteralExpression>expr).literalKind == LiteralKind.ARRAY) {
        return "[" + (<ArrayLiteralExpression>expr).elementExpressions.map((el) => {
          const value = this.defaultValue(null, el);
          if(!value) throw "Unusable default array value: " + el;
          return value;
        }).join(", ") + "]";
      }

      if(expr.kind == NodeKind.LITERAL && (<LiteralExpression>expr).literalKind == LiteralKind.OBJECT) {
        const obj = <ObjectLiteralExpression>expr;
        return "{" + obj.names.map((name, idx) => {
          const value = this.defaultValue(null, obj.values[idx]);
          if(!value) throw "Unusable default object value: " + obj.values[idx];
          return name.text + ": " + value;
        }).join(", ") + "}";
      }

      if(expr.kind == NodeKind.CALL && (<PropertyAccessExpression>(<CallExpression>expr).expression).property.text == "from") {
        return this.defaultValue(null, (<CallExpression>expr).arguments[0]);
      }

      switch (expr.kind) {
        case NodeKind.TRUE: return "true";
        case NodeKind.FALSE: return "false";
        case NodeKind.NULL: return "null";
      }
    }

    if(!type) { return null; }
    if(type.is(TypeFlags.NULLABLE)) { return "null"; }
    if(type.is(TypeFlags.REFERENCE)) {
      if(type.classReference) {
        if(type.classReference.prototype.declaration.name.text == "Str") { return "\"\""; }
        if(this.sliceType(type.classReference)) { return "[]"; }

        return "{" + Array.from(type.classReference.members || [], ([name, fieldel]: [String, DeclaredElement]) => {
          const field = <Field>fieldel;
          if(field.memoryOffset < 0 || !field.type) {
            return null;
          } else {
            const initializer = (<VariableLikeDeclarationStatement>field.declaration).initializer;
            return name + ": " + this.defaultValue(field.type, initializer);
          }
        }).filter((fld: string|null) => !!fld).join(", ") + "}";
      }

      return null;
    }

    switch (type.kind) {
      case TypeKind.I32: return "0";
      case TypeKind.U64: return "0";
      case TypeKind.BOOL: return "false";
      case TypeKind.F64: return "0.0";
      default:
        throw "cannot use primitive type " + type + " in interface";
    }

    return null;
  }

  private sliceType(klass: Class): Type|null {
    if(klass.prototype.name == "Slice" && klass.typeArguments && klass.typeArguments.length == 1) {
      return klass.typeArguments[0];
    }

    if(klass.base) {
      return this.sliceType(klass.base);
    }

    return null;
  }

  private internalNameToGraphQL(internalName: string): string {
    return internalName.trim().replace(/[^A-Za-z0-9_]+/g, "__");
  }
}

export = class GraphQLTrasform extends Transform {
  program: Program;

  afterParse(parser: Parser) {
    this.program = parser.program;
  }

  afterCompile(module: Module) {
    writeFileSync("schema", GraphQLSchemaBuilder.build(this.program));
  }
}
