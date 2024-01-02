package pine.macro.builder;

import haxe.macro.Expr;

using pine.macro.MacroTools;

class ComputedFieldBuilder implements Builder {
  public final priority:BuilderPriority = Normal;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    for (field in builder.findFieldsByMeta(':computed')) {
      parseField(builder, field.getMetadata(':computed'), field);
    }
  }

  function parseField(builder:ClassBuilder, meta:MetadataEntry, field:Field) {
    switch field.kind {
      case FVar(t, e):
        if (t == null) {
          field.pos.error('@:computed field require an explicit type');
        }
        if (e == null) {
          field.pos.error('@:computed fields require an expression');
        }
        if (!field.access.contains(AFinal)) {
          field.pos.error('@:computed fields must be final');
        }
  
        var name = field.name;
        var getterName = 'get_$name';
        var backingName = '__backing_$name';
        var createName = '__create_$name';
  
        field.name = createName;
        field.meta.push({ name: ':noCompletion', params: [], pos: (macro null).pos });
        field.kind = FFun({
          args: [],
          ret: macro:pine.signal.Computation<$t>,
          expr: macro return new pine.signal.Computation<$t>(() -> $e)
        });
  
        builder.addField({
          name: name,
          access: field.access,
          kind: FProp('get', 'never', macro:pine.signal.Computation<$t>),
          pos: (macro null).pos
        });
  
        builder.add(macro class {
          var $backingName:Null<pine.signal.Computation<$t>> = null;
  
          @:noCompletion
          inline function $getterName():pine.signal.Computation<$t> {
            pine.debug.Debug.assert(this.$backingName != null);
            return this.$backingName;
          }
        });

        builder.addHook('init:late', macro this.$backingName = this.$createName());
      default:
        meta.pos.error('Invalid field for :computed');
    }
  }
}
