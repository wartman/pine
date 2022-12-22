package pine.internal;

import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

using Lambda;
using pine.macro.MacroTools;

typedef TrackedPropertyBuilderOptions = {
  public final trackedName:String;
  public final trackerIsNullable:Bool;
  public final params:Array<String>;
} 

/**
  Finds all non-final fields of a class and converts them into
  getter/setters that in turn use an internal TrackedObject. This
  means that all non-final fields in a class will become 
  reactive States.

  Note that fields marked with `@:skip` will be ignored.
**/
class TrackedPropertyBuilder extends ClassBuilder {
  public static function fromContext(?options) {
    return new TrackedPropertyBuilder(getBuildFieldsSafe(), options);
  }

  var inits:Array<Expr> = [];
  var props:Array<Field> = [];
  var initProps:Array<Field> = [];

  final options:TrackedPropertyBuilderOptions;

  public function new(fields, ?options) {
    super(fields);
    this.options = options == null ? {
      trackedName: 'tracked',
      trackerIsNullable: false,
      params: []
    } : options;
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

  public function getTrackedObjectTypePath():TypePath {
    var props = getTrackedObjectPropsType();
    return {
      pack: [ 'pine', 'state' ],
      name: 'TrackedObject',
      params: [ TPType(props) ].concat(options.params.map(name -> TPExpr(macro $v{name})))
    };
  }

  public function getTrackedObjectType():ComplexType {
    return TPath(getTrackedObjectTypePath());
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

  public function instantiateTrackedObject(propsName = 'props'):Expr {
    var arg = getTrackedObjectConstructorArg(propsName);
    var path = getTrackedObjectTypePath();
    return macro new $path($arg);
  }

  public function getTrackedObjectExpr() {
    var name = options.trackedName;
    if (options.trackerIsNullable) {
      return macro {
        pine.debug.Debug.alwaysAssert(this.$name != null);
        this.$name;
      }
    }
    return macro this.$name;
  }

  function process() {
    for (field in fields) switch field.kind {
      case FVar(t, e) if (
        !field.access.contains(AFinal)
        && !field.access.contains(AStatic)
        && !field.meta.exists(m -> m.name == ':skip')
      ):
        var prop = field.name.makeField(t, e != null);
        var name = field.name;
        var getter = 'get_$name';
        var setter = 'set_$name';
        var tracked = this.getTrackedObjectExpr();
        
        addInitProp(prop);
        addProp(prop);

        if (e != null) {
          addInitializer(macro if (props.$name == null) {
            props.$name = $e;
          });
        }

        switch t {
          case macro:Array<$r>:
            var type = macro:pine.state.TrackedArray<$r>;
            field.kind = FProp('get', 'never', type);
            add(macro class {
              inline function $getter():$type return $tracked.$name;
            });
          case macro:Map<$k, $v>:
            var type = macro:pine.state.TrackedMap<$k, $v>;
            field.kind = FProp('get', 'never', type);
            add(macro class {
              inline function $getter():$type return $tracked.$name;
            });
          default:
            field.kind = FProp('get', 'set', t);
            add(macro class {
              inline function $getter():$t return $tracked.$name;

              inline function $setter(value:$t) {
                $tracked.$name = value;
                return value;
              }
            });
        }
      default:
    }
  }
}

