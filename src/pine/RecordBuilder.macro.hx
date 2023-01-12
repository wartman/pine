package pine;

import haxe.macro.Expr;
import pine.core.*;
import pine.macro.ClassBuilder;

using pine.macro.MacroTools;

function build() {
  var cls = haxe.macro.Context.getLocalClass().get();
  var builder = ClassBuilder.fromContext();
  var properties = new PropertyBuilder(builder.getFields());
  var tracked = new TrackedPropertyBuilder(builder.getFields(), {
    trackedName: 'tracked',
    trackerIsNullable: false,
    params: cls.params.map(p -> p.name)
  });
  var trackedInitProps = tracked.getInitializerProps();

  if (trackedInitProps.length > 0) {
    var trackedObjectProps:ComplexType = tracked.getTrackedObjectPropsType();
    var trackedType = tracked.getTrackedObjectType();
    var initProps:ComplexType = TAnonymous(properties.getProps().concat(trackedInitProps));
  
    builder.add(macro class {
      final tracked:$trackedType;

      public function new(props:$initProps) {
        @:mergeBlock ${tracked.getInitializers()};
        @:mergeBlock ${properties.getInitializers()};
        tracked = ${tracked.instantiateTrackedObject()};
      }

      public function dispose() {
        tracked.dispose();
      }
    });
  } else {
    var propsType = properties.getPropsType();
    builder.add(macro class {
      public function new(props:$propsType) {
        @:mergeBlock ${properties.getInitializers()};
      }

      public function dispose() {}
    });
  }

  return builder.merge(properties).merge(tracked).export();
}