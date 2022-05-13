package pine.macro;

import haxe.macro.Expr;

using Lambda;

class ReactivePropertyBuilder extends ClassBuilder {
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

  public inline function getObservableObjectProps() {
    return props;
  }

  public function getObservableObjectPropsType():ComplexType {
    return TAnonymous(getObservableObjectProps());
  }

  public function getObservableObjectType() {
    var props = getObservableObjectPropsType();
    return macro:pine.ObservableObject<$props>;
  }

  public function getObservableObjectConstructorArg(propsName = 'props'):Expr {
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

  public function instantiateObservableObject(propsName = 'props') {
    var props = getObservableObjectPropsType();
    var arg = getObservableObjectConstructorArg(propsName);
    return macro new pine.ObservableObject<$props>($arg);
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
