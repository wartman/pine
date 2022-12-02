package pine;

import pine.state.Engine.unbind;
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
  var controllers = new ControllerPropertyBuilder(builder.getFields());
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

      final public function asTrackable():haxe.ds.Option<pine.element.state.Trackable<Dynamic>> {
        return Some(this);
      }

      public function getTrackedObject():$trackedType {
        return trackedObject;
      }
  
      public function initTrackedObject():$trackedType {
        trackedObject = ${tracked.instantiateTrackedObject('trackedObjectProps')};
        return trackedObject;
      }

      public function reuseTrackedObject(trackedObject:$trackedType):$trackedType {
        this.trackedObject = trackedObject;
        this.trackedObject.replace(this.trackedObjectProps);
        return this.trackedObject;
      }

      override function createControllerManager(element:pine.Element):pine.element.ControllerManager {
        return new pine.element.ControllerManager(([
          $a{[ 
            macro cast new pine.element.state.TrackableController() 
          ].concat(controllers.getControllers())}
        ]:Array<pine.Controller<Dynamic>>));
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

    if (controllers.hasControllers()) {
      builder.add(macro class {
        override function createControllerManager(element:pine.Element):pine.element.ControllerManager {
          return ${controllers.getManagerInitializer()};
        }
      });
    }
  }

  return builder
    .merge(componentType)
    .merge(properties)
    .merge(tracked);
}
