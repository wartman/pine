package pine.core;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;

using Lambda;

class HookBuilder extends ClassBuilder {
  var hooks:Array<Expr> = [];

  public function new(fields) {
    super(fields);
    process();
  }

  public function hasHooks() {
    return hooks.length > 0;
  }

  public function getHooks() {
    return hooks;
  }

  public function getHookCollection() {
    return macro new pine.HookCollection([ $a{hooks} ]);
  }

  function process() {
    // @todo: The way I'm doing this here breaks completion and
    // creates a really useless error message. We need to figure out how
    // to do this correctly. 
    var meta = Context.getLocalClass().get().meta.extract(':hook');
    
    for (c in meta) {
      for (e in c.params) hooks.push(e);
    }
  }
}
