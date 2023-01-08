package pine.html;

import pine.adaptor.ObjectType;
import pine.diffing.Key;

abstract class HtmlRootComponent<T> extends RootComponent {
  final el:T;

  public function new(props:{
    el:T,
    child:Null<Component>,
    ?key:Key
  }) {
    super(props);
    this.el = props.el;
  }
  
  function getObjectType():ObjectType {
    return ObjectElement('#root');
  }

  public function getObjectData() {
    return {};
  }
  
  public function getRootObject():Dynamic {
    return el;
  }
}
