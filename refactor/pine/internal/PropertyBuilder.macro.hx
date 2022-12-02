package pine.internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

using Lambda;
using pine.macro.MacroTools;

class PropertyBuilder extends ClassBuilder {
  public static function fromContext() {
    return new PropertyBuilder(getBuildFieldsSafe());
  }

  var inits:Array<Expr> = [];
  var props:Array<Field> = [];

  public function new(fields) {
    super(fields);
    process();
  }

  public function addProp(prop:Field) {
    props.push(prop);
  }

  public function addInitializer(expr:Expr) {
    inits.push(expr);
  }

  public function getProps() {
    return props;
  }

  public function getPropsType():ComplexType {
    return TAnonymous(props);
  }

  public function getInitializers():Expr {
    return macro $b{inits};
  }

  function process() {
    for (field in findFieldsByMeta(':prop')) {
      switch field.kind {
        case FVar(t, e):
          var name = field.name;
          var meta = field.meta.find(m -> m.name == ':prop');

          if (!field.access.contains(AFinal)) {
            Context.error('All @:prop fields must be final', field.pos);
          }

          addProp(name.makeField(t, e != null));
          addInitializer(e == null ? macro this.$name = props.$name : macro if (props.$name != null) this.$name = props.$name);
        default:
      }
    }
  }
}
