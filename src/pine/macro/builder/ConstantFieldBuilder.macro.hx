package pine.macro.builder;

import haxe.macro.Expr;

using pine.macro.Tools;

class ConstantFieldBuilder implements Builder {
  public final priority:BuilderPriority = Before;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    var fields = builder.findFieldsByMeta(':constant');

    for (field in fields) {
      parseField(builder, field);
    }
  }

  function parseField(builder:ClassBuilder, field:Field) {
    switch field.kind {
      case FVar(t, e):
        if (!field.access.contains(AFinal)) {
          field.pos.error('@:constant fields must be final');
        }
  
        var name = field.name;
        
        builder.addProp('new', { name: name, type: t, optional: e != null });
        builder.addHook('init', if (e == null) {
          macro this.$name = props.$name;
        } else {
          macro if (props.$name != null) this.$name = props.$name;
        });
      default:
        field.pos.error('Invalid field for :constant');
    }
  }
}
