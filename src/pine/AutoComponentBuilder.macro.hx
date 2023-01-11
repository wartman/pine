package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;
import pine.core.*;

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
      final public function getTrackedObjectManager():haxe.ds.Option<pine.AutoComponent.TrackedObjectManager<Dynamic>> {
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

      public function createElement() {
        return new pine.Element(
          this,
          pine.AutoComponent.useTrackedElementEngine((element:pine.ElementOf<pine.AutoComponent>) -> element.component.render(element)),
          new pine.HookCollection([$a{[
            macro cast pine.AutoComponent.syncTrackedObject()
          ].concat(hooks.getHooks())}])
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
      
      final public function getTrackedObjectManager():haxe.ds.Option<pine.AutoComponent.TrackedObjectManager<Dynamic>> {
        return None;
      }

      public function createElement() {
        return new pine.Element(
          this,
          pine.AutoComponent.useTrackedElementEngine((element:pine.ElementOf<AutoComponent>) -> element.component.render(element)),
          ${if (hooks.hasHooks()) hooks.getHookCollection() else macro []}
        );
      }
    });
  }

  return builder
    .merge(properties)
    .merge(tracked)
    .export();
}
