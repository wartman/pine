package pine;

import pine.signal.Computation;
import pine.signal.Signal;

@:forward
abstract Children(Array<Child>) from Array<Child> to Array<Child> to Array<ViewBuilder> {
  @:from public inline static function ofBuilder(child:ViewBuilder):Children {
    return [ child ];
  }

  @:from
  public inline static function ofComputationString(content:Computation<String>):Children {
    return [ content ];
  }

  @:from
  public inline static function ofReadOnlySignalString(content:ReadOnlySignal<String>):Children {
    return [ content ];
  }

  @:from
  public inline static function ofSignalString(content:Signal<String>):Children {
    return [ content ];
  }

  @:from public inline static function ofText(child:Text):Children {
    return [ child ];
  }

  @:from public inline static function ofChild(child:Child):Children {
    return [ child ];
  }

  @:from public inline static function ofString(content:String):Children {
    return [ new Text(content) ];
  }
}
