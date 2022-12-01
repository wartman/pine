package pine.core;

import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

function build() {
  return process(getBuildFieldsSafe()).export();
}

function process(fields) {
  var builder = new ClassBuilder(fields);

  switch builder.findField('getComponentType') {
    case Some(_): return builder;
    case None:
  }

  builder.add(macro class {
    public static final componentType:pine.internal.UniqueId = new pine.internal.UniqueId();

    public function getComponentType():pine.internal.UniqueId {
      return componentType;
    }
  });
  
  return builder;
}
