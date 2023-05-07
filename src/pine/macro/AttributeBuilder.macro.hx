package pine.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

function build() {
  var builder = ClassBuilder.fromContext();
  var attrs:Array<Expr> = [];

  for (field in builder.findFieldsByMeta(':attr')) {
    var name = field.name;
    var attr = field.meta.find(m -> m.name == ':attr');
    var attrName = switch attr.params {
      case [ expr ]: switch expr.expr {
        case EConst(CString(s)): 
          s;
        default: 
          Context.error('Expected a string', expr.pos);
      }
      case []: 
        name;
      default: 
        Context.error('Expected 1 or 0 arguments', attr.pos);
    }
    attrs.push(macro if (this.$name != null) attributes.set($v{attrName}, this.$name));
  }
  
  builder.add(macro class {
    function getAttributes():Map<String, pine.signal.Signal.ReadonlySignal<Any>> {
      var attributes:Map<String, pine.signal.Signal.ReadonlySignal<Any>> = [];
      @:mergeBlock $b{attrs};
      return attributes;
    }
  });

  return builder.export();
}