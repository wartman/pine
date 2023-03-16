package pine.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

using Kit;
using StringTools;
using haxe.macro.Tools;
using pine.core.Hash;

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

function typePathToString(path:TypePath) {
  return path.pack.concat([path.name]).join('.');
}

function makeField(name:String, type:ComplexType, optional:Bool):Field {
  var pos = (macro null).pos;
  return {
    name: name,
    pos: pos,
    meta: optional ? [{name: ':optional', pos: pos}] : [],
    kind: FVar(type, null)
  };
}

// Workaround for https://github.com/HaxeFoundation/haxe/issues/9853
// Stolen from https://github.com/haxetink/tink_macro/blob/6f4e6b9227494caddebda5659e0a36d00da9ca52/src/tink/MacroApi.hx#L70
private function getCompletion():Maybe<{ file:String, content:String, pos:Int }> {
  var sysArgs = Sys.args();
  return switch sysArgs.indexOf('--display') {
    case -1: None;
    case sysArgs[_ + 1] => arg if (arg.startsWith('{"jsonrpc":')):
      var payload:{
        jsonrpc:String,
        method:String,
        params:{
          file:String,
          offset:Int,
          contents:String,
        }
      } = haxe.Json.parse(arg);
      switch payload {
        case {jsonrpc: '2.0', method: 'display/completion'}:
          Some({
            file: payload.params.file,
            content: payload.params.contents,
            pos: payload.params.offset,
          });
        default: None;
      }
    default: None;
  }
}

function getBuildFieldsSafe():Array<Field> {
  return switch getCompletion() {
    case Some(v) if (v.content != null
      && (v.content.charAt(v.pos - 1) == '@' || (v.content.charAt(v.pos - 1) == ':' && v.content.charAt(v.pos - 2) == '@'))):
      Context.error('Impossible to get builds fields now. Possible cause: https://github.com/HaxeFoundation/haxe/issues/9853', Context.currentPos());
    default:
      Context.getBuildFields();
  }
}
