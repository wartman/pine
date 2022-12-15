package pine.internal;

import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

using Lambda;
using pine.macro.MacroTools;

/**
  Finds all the `final` fields of a class and builds an
  initializer for them.

  Final members marked with `@:skip` will not be included.
**/
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
    for (field in fields) switch field.kind {
      case FVar(t, e) if (
        field.access.contains(AFinal)
        && !field.access.contains(AStatic)
        && !field.meta.exists(m -> m.name == ':skip' || m.name == ':lazy')
      ):
        var name = field.name;
        addProp(name.makeField(t, e != null));
        addInitializer(e == null ? macro this.$name = props.$name : macro if (props.$name != null) this.$name = props.$name);
      default:
    }
  }
}
