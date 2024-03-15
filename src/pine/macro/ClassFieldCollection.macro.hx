package pine.macro;

import haxe.macro.Expr;

using Lambda;

class ClassFieldCollection {
  final fields:Array<Field>;
  var newFields:Array<Field> = [];
  
  public function new(fields) {
    this.fields = fields;
  }

  public function getFields() {
    return fields;
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

  public function merge(collection:ClassFieldCollection) {
    mergeFields(collection.newFields);
    return this;
  }

  public function findField(name:String):Maybe<Field> {
    return switch fields.find(f -> f.name == name) {
      case null: None;
      case field: Some(field);
    }
  }

  public function findFieldsByMeta(name:String):Array<Field> {
    return fields.filter(f -> f.meta.exists(m -> m.name == name));
  }

  public function export():Array<Field> {
    return fields.concat(newFields);
  }
}
