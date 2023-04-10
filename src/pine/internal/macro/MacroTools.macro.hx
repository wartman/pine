package pine.internal.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;
using haxe.macro.Tools;
using pine.internal.Hash;

function typeExists(name:String) {
  try {
    return Context.getType(name) != null;
  } catch (e:String) {
    return false;
  }
}

function typePathExists(path:TypePath) {
  return typeExists(typePathToString(path));
}

function typePathToString(path:TypePath) {
  return path.pack.concat([path.name]).join('.');
}

function parseAsType(name:String):ComplexType {
  return switch Context.parse('(null:${name})', Context.currentPos()) {
    case macro(null : $type): type;
    default: null;
  }
}

function resolveComplexType(expr:Expr):ComplexType {
  return switch expr.expr {
    case ECall(e, params):
      var tParams = params.map(param -> resolveComplexType(param).toString()).join(',');
      parseAsType(resolveComplexType(e).toString() + '<' + tParams + '>');
    default: switch Context.typeof(expr) {
      case TType(_, _):
        parseAsType(expr.toString());
      default:
        Context.error('Invalid expression', expr.pos);
        null;
    }
  }
}

function stringifyTypeForClassName(type:haxe.macro.Type):String {
  return switch type {
    // Attempt to use human-readable names if possible
    case TInst(t, []): 
      type.toString().replace('.', '_');
    case TInst(t, params):
      t.toString().replace('.', '_') + '__' + params.map(stringifyTypeForClassName).join('_'); 
    default: 
      // Fallback to using a hash.
      type.toString().hash();
  }
}