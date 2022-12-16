package pine.core;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

using Lambda;

function build() {
  return process(getBuildFieldsSafe()).export();
}

function process(fields) {
  var builder = new ClassBuilder(fields);

  if (hasComponentType(Context.getLocalClass().get())) {
    return builder;
  }

  builder.add(macro class {
    public static final componentType:pine.internal.UniqueId = new pine.internal.UniqueId();

    public function getComponentType():pine.internal.UniqueId {
      return componentType;
    }
  });
  
  return builder;
}

function hasComponentType(cls:ClassType) {
  if (cls.fields.get().exists(f -> 
    f.name == 'getComponentType' && !f.isAbstract
  )) return true;

  if (cls.superClass != null) {
    return hasComponentType(cls.superClass.t.get());
  }
  
  return false;
}
