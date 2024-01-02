package pine.macro.builder;

import haxe.macro.Expr;

using pine.macro.MacroTools;

class ObservableFieldBuilder implements Builder {
  public final priority:BuilderPriority = Before;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    for (field in builder.findFieldsByMeta(':observable')) {
      parseField(builder, field.getMetadata(':observable'), field);
    }
  }

  function parseField(builder:ClassBuilder, meta:MetadataEntry, field:Field) {
    var name = field.name;

    if (!field.access.contains(AFinal)) {
      field.pos.error(':observable fields must be final');
    }

    switch field.kind {
      case FVar(t, e):
        var type = switch t {
          case macro:Null<$t>: macro:pine.signal.Signal.ReadOnlySignal<Null<$t>>;
          default: macro:pine.signal.Signal.ReadOnlySignal<$t>;
        }
        
        field.kind = FVar(type, switch e {
          case macro null: macro new pine.signal.Signal(null);
          default: e;
        });

        builder.addProp('new', {
          name: name,
          type: type,
          optional: e != null
        });
        builder.addHook('init:late', if (e == null) {
          macro this.$name = props.$name;
        } else {
          macro if (props.$name != null) this.$name = props.$name;
        });
      default:
        meta.pos.error(':observable cannot be used here');
    }
  }
}