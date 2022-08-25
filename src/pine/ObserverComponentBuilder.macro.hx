package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.ClassMetaDebugger;
import pine.macro.ImmutablePropertyBuilder;
import pine.macro.TrackedPropertyBuilder;

using Lambda;
using haxe.macro.Tools;
using pine.macro.MacroTools;

function build() {
  var fields = MacroTools.getBuildFieldsSafe();
  var builder = new ClassBuilder(fields);
  var trackedBuilder = new TrackedPropertyBuilder(fields, { trackedName: 'trackedObject', trackerIsNullable: true });
  var immutableBuilder = new ImmutablePropertyBuilder(fields);

  immutableBuilder.addProp(MacroTools.makeField('key', macro:pine.Key, true));

  if (Context.defined('debug')) {
    var debugger = new ClassMetaDebugger(fields, ['prop', 'track'], [
      ':prop' => 'Use `@prop` instead of `@:prop`.',
      ':track' => 'Use `@track` instead of `@:track`.'
    ]);
    debugger.check();
  }

  var trackedObjectProps:ComplexType = trackedBuilder.getTrackedObjectPropsType();
  var initProps:ComplexType = TAnonymous(trackedBuilder.getInitializerProps().concat(immutableBuilder.getProps()));
  var trackedType = trackedBuilder.getTrackedObjectType();

  builder.add(macro class {
    public static final componentType = new pine.UniqueId();

    var trackedObject:Null<$trackedType> = null;
    final trackedObjectProps:$trackedObjectProps;

    public function getComponentType() {
      return componentType;
    }

    public function new(props:$initProps) {
      super(props.key);
      ${trackedBuilder.getInitializers()};
      ${immutableBuilder.getInitializers()};
      trackedObjectProps = ${trackedBuilder.getTrackedObjectConstructorArg()};
    }

    function getTrackedObject() {
      return trackedObject;
    }

    function createTrackedObject() {
      trackedObject = ${trackedBuilder.instantiateTrackedObject('trackedObjectProps')};
      return trackedObject;
    }

    function reuseTrackedObject(trackedObject:Dynamic) {
      this.trackedObject = trackedObject;
      this.trackedObject.replace(this.trackedObjectProps);
      return this.trackedObject;
    }
  });

  return builder.merge(immutableBuilder).merge(trackedBuilder).export();
}
