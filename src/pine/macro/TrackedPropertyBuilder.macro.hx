package pine.macro;

import haxe.macro.Expr;

using Lambda;

class TrackedPropertyBuilder extends ClassBuilder {
  var inits:Array<Expr> = [];
  var props:Array<Field> = [];
  var initProps:Array<Field> = [];

  public function new(fields) {
    super(fields);
    process();
  }

  public function addProp(prop) {
    props.push(prop);
  }

  public function addInitProp(prop) {
    initProps.push(prop);
  }

  public function addInitializer(expr:Expr) {
    inits.push(expr);
  }

  public function getInitializers():Expr {
    return macro $b{inits};
  }

  public inline function getInitializerProps() {
    return initProps;
  }

  public function getInitializerPropsType():ComplexType {
    return TAnonymous(getInitializerProps());
  }

  public inline function getTrackedObjectProps() {
    return props;
  }

  public function getTrackedObjectPropsType():ComplexType {
    return TAnonymous(getTrackedObjectProps());
  }

  public function getTrackedObjectType() {
    var props = getTrackedObjectPropsType();
    return macro:pine.track.TrackedObject<$props>;
  }

  public function getTrackedObjectConstructorArg(propsName = 'props'):Expr {
    var fields:Array<ObjectField> = [
      for (prop in props) {
        var name = prop.name;
        {field: name, expr: macro $i{propsName}.$name}
      }
    ];
    return {
      expr: EObjectDecl(fields),
      pos: (macro null).pos
    };
  }

  public function instantiateTrackedObject(propsName = 'props') {
    var props = getTrackedObjectPropsType();
    var arg = getTrackedObjectConstructorArg(propsName);
    return macro new pine.track.TrackedObject<$props>($arg);
  }

  function process() {
    for (field in findFieldsByMeta('observe')) {
      switch field.kind {
        case FVar(t, e):
          var prop = MacroTools.makeField(field.name, t, e != null);
          var name = field.name;
          var getter = 'get_$name';
          var setter = 'set_$name';

          addInitProp(prop);
          addProp(prop);

          if (e != null) {
            addInitializer(macro if (props.$name == null) {
              props.$name = $e;
            });
          }

          if (field.access.contains(AFinal)) {
            field.kind = FProp('get', 'never', t);
            add(macro class {
              inline function $getter():$t return observable.$name;
            });
          } else {
            field.kind = FProp('get', 'set', t);

            add(macro class {
              inline function $getter():$t return observable.$name;

              inline function $setter(value) {
                observable.$name = value;
                return value;
              }
            });
          }
        default:
      }
    }

    // for (field in fields) {
    //   switch field.kind {
    //     case FFun(f) if (field.meta.exists(f -> f.name == 'transition')):
    //     // @todo
    //     default:
    //   }
    // }
  }
}
