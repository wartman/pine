package pine.macro;

import haxe.ds.Option;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;
using haxe.macro.Tools;

class MacroTools {
  public static function typeExists(name:String) {
    try {
      return Context.getType(name) != null;
    } catch (e:String) {
      return false;
    }
  }

  public static function typePathExists(path:TypePath) {
    return typeExists(typePathToString(path));
  }

  public static function parseAsType(name:String):ComplexType {
    return switch Context.parse('(null:${name})', Context.currentPos()) {
      case macro(null : $type): type;
      default: null;
    }
  }

  public static function resolveComplexType(expr:Expr):ComplexType {
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

  public static function stringifyTypeForClassName(type:haxe.macro.Type) {
    return haxe.crypto.Md5.encode(type.toString());
  }

  public static function typePathToString(path:TypePath) {
    return path.pack.concat([path.name]).join('.');
  }

  public static function makeField(name:String, type:ComplexType, optional:Bool):Field {
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
  static function getCompletion() {
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

  public static function getBuildFieldsSafe():Array<Field> {
    return switch getCompletion() {
      case Some(v) if (v.content != null
        && (v.content.charAt(v.pos - 1) == '@' || (v.content.charAt(v.pos - 1) == ':' && v.content.charAt(v.pos - 2) == '@'))):
        Context.error('Impossible to get builds fields now. Possible cause: https://github.com/HaxeFoundation/haxe/issues/9853', Context.currentPos());
      default:
        Context.getBuildFields();
    }
  }
}
