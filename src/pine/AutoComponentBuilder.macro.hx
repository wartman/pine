package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.core.*;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

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

      public function createElement() {
        return new pine.Element(
          this,
          pine.element.TrackedElementEngine.useSyncedTrackedProxyEngine((element:pine.ElementOf<$ct>) -> element.component.render(element), {
            init: (component:$ct) -> {
              var trackedObjectProps = component.trackedObjectProps;
              var trackedObject = ${tracked.instantiateTrackedObject('trackedObjectProps')};
              component.trackedObject = trackedObject;
              return trackedObject;
            },
            bind: (component:$ct, trackedObject:$trackedType) -> {
              component.trackedObject = trackedObject;
              component.trackedObject.replace(component.trackedObjectProps);
            }
          }),
          ${hooks.getHookCollection()}
        );
      }
    });
  } else {
    var propsType = properties.getPropsType();

    builder.add(macro class {
      public function new(props:$propsType) {
        super(props.key);
        @:mergeBlock ${properties.getInitializers()}
      }

      public function createElement() {
        return new pine.Element(
          this,
          pine.element.TrackedElementEngine.useTrackedProxyEngine((element:pine.ElementOf<AutoComponent>) -> element.component.render(element)),
          ${hooks.getHookCollection()}
        );
      }
    });
  }

  return builder
    .merge(properties)
    .merge(tracked)
    .export();
}
