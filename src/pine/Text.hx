package pine;

import pine.adaptor.ObjectType;
import pine.core.HasComponentType;

abstract Text(TextComponent) to TextComponent to Component {
  @:from public inline static function ofString(content:String) {
    return new Text(content);
  }

  @:from public inline static function ofInt(content:Int) {
    return new Text(content + '');
  }

  @:from public inline static function ofFloat(content:Float) {
    return new Text(content + '');
  }

  public inline function new(content, ?key) {
    this = new TextComponent(content, key);
  }
}

final class TextComponent extends ObjectComponent implements HasComponentType {
  final content:String;

  public function new(content, ?key) {
    super(key);
    this.content = content;
  }

  public function getObjectType():ObjectType {
    return ObjectText;
  }

  public function getObjectData():Dynamic {
    return content;
  }

  public function render():Null<Array<Component>> {
    return null;
  }
}
