package pine;

@:forward
abstract Child(Component) from Text from Component to Component {
  @:from
  public inline static function ofString(content:String):Child {
    return (content:Text);
  }

  @:from
  public inline static function ofInt(content:Int):Child {
    return (content:Text);
  }

  @:from
  public inline static function ofFloat(content:Float):Child {
    return (content:Text);
  }
}
