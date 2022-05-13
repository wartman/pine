package pine.macro;

import haxe.ds.Option;
import haxe.macro.Expr;

using Lambda;

class ClassBuilder {
  var fields:Array<Field>;
  var newFields:Array<Field> = [];

  public function new(fields) {
    this.fields = fields;
  }

  public function add(t:TypeDefinition) {
    mergeFields(t.fields);
    return this;
  }

  public function addField(f:Field) {
    newFields.push(f);
    return this;
  }

  public function mergeFields(fields:Array<Field>) {
    newFields = newFields.concat(fields);
    return this;
  }

  public function merge(builder:ClassBuilder) {
    mergeFields(builder.newFields);
    return this;
  }

  public function export() {
    return fields.concat(newFields);
  }

  public function findField(name:String):Option<Field> {
    return switch fields.find(f -> f.name == name) {
      case null: None;
      case field: Some(field);
    }
  }

  public function findFieldsByMeta(name:String) {
    return fields.filter(f -> f.meta.exists(m -> m.name == name));
  }
}
