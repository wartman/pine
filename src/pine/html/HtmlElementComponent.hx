package pine.html;

import pine.adapter.*;
import pine.element.*;
import pine.diffing.Key;
import pine.element.object.DirectChildrenManager;
#if debug
import pine.debug.Debug;
#end

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
    return ObjectElement(tag);
  }

  public function getObjectData() {
    return attrs;
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new DirectChildrenManager<HtmlElementComponent<Attrs>>(
      element, 
      element -> {
        var children = element.component.children;
        if (children == null) return [];
        return children;
      }
    );
  }
}
