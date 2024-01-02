package pine.macro.builder;

import haxe.macro.Expr;

using pine.macro.MacroTools;

class AttributeFieldBuilder implements Builder {
  public final priority:BuilderPriority = Before;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    var fields = builder.findFieldsByMeta(':attribute');
    for (field in fields) {
      parseField(builder, field);
    }
  }

  function parseField(builder:ClassBuilder, field:Field) {
    switch field.kind {
      case FVar(t, e):
        var name = field.name;
        builder.addProp('new', { name: name, type: t, optional: e != null });
        builder.addHook('init', if (e == null) {
          macro this.$name = props.$name;
        } else {
          macro if (props.$name != null) this.$name = props.$name;
        });
      default:
        field.pos.error('Invalid field for :attribute');
    }
  }
}

