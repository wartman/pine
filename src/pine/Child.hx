package pine;

import pine.signal.Computation;
import pine.signal.Signal;

@:forward
abstract Child(View) 
  from Text
  from View
  from Component
  to View 
{
  @:from public inline static function ofComputationString(content:Computation<String>):Child {
    return new Text(content);
  }

  @:from public inline static function ofReadOnlySignalString(content:ReadOnlySignal<String>):Child {
    return new Text(content);
  }

  @:from public inline static function ofSignalString(content:Signal<String>):Child {
    return new Text(content);
  }

  @:from public inline static function ofString(content:String):Child {
    return (content:Text);
  }

  @:from public inline static function ofInt(content:Int):Child {
    return (content:Text);
  }

  @:from public inline static function ofFloat(content:Float):Child {
    return (content:Text);
  }

  @:from public inline static function ofChildren(children:Children):Child {
    return Fragment.of(children);
  }
}
