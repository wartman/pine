package pine.internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;

using Lambda;

class ControllerPropertyBuilder extends ClassBuilder {
  var controllers:Array<Expr> = [];

  public function new(fields) {
    super(fields);
    process();
  }

  public function hasControllers() {
    return controllers.length > 0;
  }

  public function getControllers() {
    return controllers;
  }

  public function getManagerInitializer() {
    return macro new pine.element.ControllerManager([ $a{controllers} ]);
  }

  function process() {
    var meta = Context.getLocalClass().get().meta.extract(':controller');
    
    for (c in meta) {
      for (e in c.params) controllers.push(macro @:pos(e.pos) $e);
    }
  }
}
