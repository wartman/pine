package pine;

import haxe.macro.Expr;
import pine.macro.*;
import pine.macro.builder.*;

using pine.macro.MacroTools;
using Lambda;

final factory = new ClassBuilderFactory([
  new ActionFieldBuilder(),
  new AttributeFieldBuilder(),
  new ObservableFieldBuilder(),
  new ConstructorBuilder({}),
  new ComponentBuilder()
]);

function build() {
  return factory.fromContext().export();
}

class ComponentBuilder implements Builder {
  public final priority:BuilderPriority = Late;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    var props = builder.getProps('new');
    var cls = builder.getClass();
    var tp = builder.getTypePath();
    var params = cls.params.toTypeParamDecl();
    var propType:ComplexType = TAnonymous(props);
    var constructors = macro class {
      @:noUsing public inline static function build(props:$propType) {
        return new $tp(props);
      }
    }

    switch builder.findField('build') {
      case None:
      case Some(field):
        field.pos.error('The name "build" is reserved for components');
    }
  
    builder.addField(constructors
      .getField('build')
      .unwrap()
      .applyParameters(params));

    for (prop in props) {
      var name = prop.name;
      var field = builder.findField(name).orThrow();
      switch field.kind {
        case FVar(_, _) if (!field.access.contains(AFinal) && !!field.access.contains(AStatic)):
          var withName = 'with' + name.charAt(0).toUpperCase() + name.substr(1);
          builder.add(macro class {
            public function $withName(value) {
              this.$name = value;
              return this;
            }
          });
        default:
      }
    }
  }
}
