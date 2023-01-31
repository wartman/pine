package pine;

@:forward(iterator)
abstract Children(Array<Child>) 
  from Array<Child> 
  to Array<Child>
{
  @:from
  public inline static function ofComponent(child:Component):Children {
    return [ child ];
  }

  @:from
  public inline static function ofString(content:String):Children {
    return [ new Text(content) ];
  }

  @:to public inline function toArray():Array<Component> {
    return this;
  }
}
