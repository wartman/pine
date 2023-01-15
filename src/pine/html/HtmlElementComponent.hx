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
    isSvg = props.isSvg == null ? false : props.isSvg;
    children = props.children;
  }

  function getObjectType():ObjectType {
    if (isSvg) return ObjectElement('svg:' + tag);
    return ObjectElement(tag);
  }

  public function getObjectData() {
    return attrs;
  }

  public function render() {
    return children;
  }
}
