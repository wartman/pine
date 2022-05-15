package pine.debug;

import pine.render.Object;

enum DebugNodeType {
  WarningNode;
  ElementNode(el:Element);
}

class DebugNode extends Object {
  final type:DebugNodeType;
  final message:Null<String>;

  public function new(props:{
    type:DebugNodeType,
    ?message:String
  }) {
    type = props.type;
    message = props.message;
  }

  public function toString():String {
    return '';
  }
}
