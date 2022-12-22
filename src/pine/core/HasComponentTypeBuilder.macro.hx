package pine.core;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

using Lambda;

function build() {
  var fields = getBuildFieldsSafe();
  var builder = new ClassBuilder(fields);

  if (hasComponentType(Context.getLocalClass().get())) {
    return builder.export();
  }

  builder.add(macro class {
    public static final componentType:pine.internal.UniqueId = new pine.internal.UniqueId();

    public function getComponentType():pine.internal.UniqueId {
      return componentType;
    }
  });
  
  return builder.export();
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
