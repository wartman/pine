package pine.html;

import pine.adaptor.*;
import pine.diffing.Key;

abstract class HtmlElementComponent<Attrs:{}> extends ObjectComponent {
  public final tag:String;
  public final attrs:Attrs;
  public final isSvg:Bool;
  public final children:Null<Array<Component>>;

  public function new(props:{
    tag:String,
    attrs:Attrs,
    ?isSvg:Bool,
    ?children:Array<Component>,
    ?key:Key
  }) {
    super(props.key);
    tag = props.tag;
    attrs = props.attrs;
    isSvg = props.isSvg ?? false;
    children = props.children;
  }

  function getObjectType():ObjectType {
    if (isSvg) return ObjectElement('svg:' + tag);
    return ObjectElement(tag);
  }

  public function getObjectData() {
    return attrs;
  }

  public function getChildren() {
    return children;
  }
}
