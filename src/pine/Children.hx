package pine;

import pine.signal.Computation;
import pine.signal.Signal;

@:forward
abstract Children(ReadonlySignal<Array<Child>>) 
  from ReadonlySignal<Array<Child>>
  from Computation<Array<Child>>
  to ReadonlySignal<Array<Child>> 
{
  @:from
  public inline static function ofArray(children:Array<Child>):Children {
    return new ReadonlySignal(children);
  }
  
  @:from
  public inline static function ofComponent(child:Component):Children {
    return [ child ];
  }

  @:from
  public inline static function ofChild(child:Child):Children {
    return [ child ];
  }

  @:from
  public inline static function ofString(content:String):Children {
    return [ new Text(content) ];
  }

  @:to 
  public inline function toArray():Array<Component> {
    return this.peek();
  }
}
