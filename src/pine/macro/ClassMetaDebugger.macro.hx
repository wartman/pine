package pine.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

class ClassMetaDebugger {
  final fields:Array<Field>;
  final allowedMeta:Array<String>;
  final warnings:Map<String, String>;

  public function new(fields, allowedMeta, ?warnings) {
    this.fields = fields;
    this.allowedMeta = allowedMeta;
    this.warnings = warnings == null ? [] : warnings;
  }

  public function check() {
    for (field in fields) {
      for (meta in field.meta) {
        if (!allowedMeta.contains(meta.name)) {
          var warning = warnings.get(meta.name);
          if (warning == null) {
            warning = '`@${meta.name}` is not valid Pine metadata. The following metadata is valid this class: ${allowedMeta.map(name -> '`@$name`').join(', ')}';
          }
          Context.warning(warning, meta.pos);
        }
      }
    }
  }
}
