package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;
import pine.internal.*;

using haxe.macro.Tools;
using pine.macro.MacroTools;

function build() {
  return process(getBuildFieldsSafe()).export();
}

function process(fields) {
  var builder = new ClassBuilder(fields);
  var componentType = pine.core.HasComponentTypeBuilder.process(builder.getFields());
  var properties = new PropertyBuilder(builder.getFields());
  var tracked = new TrackedPropertyBuilder(builder.getFields(), {
    trackedName: 'trackedObject',
    trackerIsNullable: true
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

      function getTrackedObject() {
        return trackedObject;
      }
  
      function createTrackedObject() {
        trackedObject = ${tracked.instantiateTrackedObject('trackedObjectProps')};
        return trackedObject;
      }

      function reuseTrackedObject(trackedObject:Dynamic) {
        this.trackedObject = trackedObject;
        this.trackedObject.replace(this.trackedObjectProps);
        return this.trackedObject;
      }

      final function createLifecycleHooks():Null<pine.element.LifecycleHooks> {
        return {
          // @todo: Pull this out into a static object we can just return here?
          // Otherwise this will get repeated a LOT in our apps.
          //
          // Alternatively: is there a better way to handle the TrackedObject?
          // Do we just REALLY discourage using @track?
          beforeInit:(element:pine.Element) -> {
            var comp:$ct = element.getComponent();
            comp.createTrackedObject();
          },

          beforeUpdate: (
            element:pine.Element,
            currentComponent:pine.Component,
            incomingComponent:pine.Component
          ) -> {
            if (currentComponent == incomingComponent) return;
            var cur:$ct = cast currentComponent;
            var inc:$ct = cast incomingComponent;
            inc.reuseTrackedObject(cur.trackedObject);
          },

          onDispose: (element:pine.Element) -> {
            var obj = (element.getComponent():$ct).getTrackedObject();
            if (obj != null) obj.dispose();
          }
        };
      } 
    });
  } else {
    var propsType = properties.getPropsType();
    builder.add(macro class {
      public function new(props:$propsType) {
        super(props.key);
        @:mergeBlock ${properties.getInitializers()}
      }
      
      final function createLifecycleHooks():Null<pine.element.LifecycleHooks> {
        return null;
      }
    });
  }

  return builder
    .merge(componentType)
    .merge(properties)
    .merge(tracked);
}
