package pine.html;

import haxe.macro.Expr;
import haxe.macro.Context;
import pine.macro.ClassFieldCollection;

using StringTools;
using haxe.macro.Tools;

class Html {
  public static function template(expr:Expr) {
    static var generator:Null<pine.parse.Generator> = null;
      
    if (generator == null) {
      generator = new pine.parse.Generator(new pine.parse.TagContext(Root, [
        'pine.html.HtmlTags'
      ]));
    }
  
    var parser = new pine.parse.Parser(expr, {
      generateExpr: generator.generate
    });
    
    return parser.toExpr();
  }
}

// @todo: This will only check global attributes.
function buildAttributeEnum() {
  var enumFields = new ClassFieldCollection(Context.getBuildFields());
  var names = Context.getType('pine.html.HtmlAttributes.GlobalAttr');
  
  switch names {
    case TType(t, _): switch t.get().type {
      case TAnonymous(a):
        var refFields = a.get().fields;
        for (field in refFields) {
          var name = field.name.charAt(0).toUpperCase() + field.name.substr(1);
          var value = switch field.meta.extract(':attr') {
            case [ meta ]: switch meta.params {
              case [ { expr: EConst(CString(s, _)), pos: _ } ]:
                s;
              default: 
                field.name;
            }
            default: 
              field.name.toLowerCase();
          }

          enumFields.add(macro class {
            final $name = $v{value};
          });
        }
      default: throw 'assert';
    }
    default: throw 'assert';
  }
  
  return enumFields.export();
}

function buildEventEnum() {
  var enumFields = new ClassFieldCollection(Context.getBuildFields());
  var names = Context.getType('pine.html.HtmlEvents');

  switch names {
    case TType(t, _): switch t.get().type {
      case TAnonymous(a):
        var refFields = a.get().fields;
        for (field in refFields) {
          var refName = field.name;

          if (refName.startsWith('on')) {
            refName = refName.substr(2);
          }

          var name = refName.charAt(0).toUpperCase() + refName.substr(1);
          var value = refName.toLowerCase();
          enumFields.add(macro class {
            final $name = $v{value};
          });
        }
      default: throw 'assert';
    }
    default: throw 'assert';
  }

  return enumFields.export();
}
