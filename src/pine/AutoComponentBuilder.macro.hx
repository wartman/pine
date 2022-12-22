package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;
import pine.internal.*;

using haxe.macro.Tools;
using pine.macro.MacroTools;

function build() {
  var cls = Context.getLocalClass().get();
  var fields = getBuildFieldsSafe();
  var builder = new ClassBuilder(fields);
  var properties = new PropertyBuilder(fields);
  var hooks = new HookBuilder(fields);
  var tracked = new TrackedPropertyBuilder(fields, {
    trackedName: 'trackedObject',
    trackerIsNullable: true,
    params: cls.params.map(param -> param.name)
  });
  var trackedInitProps = tracked.getInitializerProps();
  
  properties.addProp('key'.makeField(macro:pine.diffing.Key, true));

  if (trackedInitProps.length > 0) {
    var ct = Context.getLocalType().toComplexType();
    var trackedObjectProps:ComplexType = tracked.getTrackedObjectPropsType();
    var trackedType = tracked.getTrackedObjectType();
    var initProps:ComplexType = TAnonymous(properties.getProps().concat(trackedInitProps));

    builder.add(macro class {
      var trackedObject:Null<$trackedType> = null;
      final trackedObjectProps:$trackedObjectProps;

      public function new(props:$initProps) {
        super(props.key);
        @:mergeBlock ${tracked.getInitializers()};
        @:mergeBlock ${properties.getInitializers()};
        trackedObjectProps = ${tracked.getTrackedObjectConstructorArg()};
      }

      @:noCompletion
      final public function asTrackable():haxe.ds.Option<pine.element.state.Trackable<Dynamic>> {
        return Some(this);
      }

      @:noCompletion
      public function getTrackedObject():$trackedType {
        return trackedObject;
      }
  
      @:noCompletion
      public function initTrackedObject():$trackedType {
        trackedObject = ${tracked.instantiateTrackedObject('trackedObjectProps')};
        return trackedObject;
      }

      @:noCompletion
      public function reuseTrackedObject(trackedObject:$trackedType):$trackedType {
        this.trackedObject = trackedObject;
        this.trackedObject.replace(this.trackedObjectProps);
        return this.trackedObject;
      }

      override function createHooks():pine.HookCollection<$ct> {
        return [$a{[
          macro cast pine.element.state.Trackable.syncTrackedObject()
        ].concat(hooks.getHooks())}];
      }
    });
  } else {
    var propsType = properties.getPropsType();

    builder.add(macro class {
      public function new(props:$propsType) {
        super(props.key);
        @:mergeBlock ${properties.getInitializers()}
      }
      
      final public function asTrackable():haxe.ds.Option<pine.element.state.Trackable<Dynamic>> {
        return None;
      }
    });

    if (hooks.hasHooks()) {
      builder.add(macro class {
        override function createHooks():pine.HookCollection<Dynamic> {
          return ${hooks.getHookCollection()};
        }
      });
    }
  }

  return builder
    .merge(properties)
    .merge(tracked)
    .export();
}
