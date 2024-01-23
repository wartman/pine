package pine.macro.builder;

import haxe.macro.Context;

using Lambda;
using pine.macro.MacroTools;

class ActionFieldBuilder implements Builder {
  public final priority:BuilderPriority = Before;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    for (field in builder.findFieldsByMeta(':action')) {
      var meta = field.meta.find(m -> m.name == ':action');
      Context.warning(':action is no longer needed', meta.pos);
    }
    
    // for (field in builder.findFieldsByMeta(':action')) switch field.kind {
    //   case FFun(f):
    //     if (f.ret != null && f.ret != macro:Void) {
    //       field.pos.error(':action methods cannot return anything');
    //     }
    //     var expr = f.expr;
    //     f.expr = macro pine.signal.Action.run(() -> $expr);
    //   default:
    //     field.pos.error(':action fields must be functions');
    // }
  }
}
