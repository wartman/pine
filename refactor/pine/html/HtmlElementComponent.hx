package pine.html;

import pine.element.core.MultipleChildrenManager;
import pine.element.*;
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

  function createChildrenManager(element:Element):ChildrenManager {
    return new MultipleChildrenManager(element, context -> {
      var component:HtmlElementComponent<Attrs> = context.getComponent();
      var children = component.children;
      if (children == null) return [];
      return children;
    });
  }

  function createLifecycleHooks():Null<LifecycleHooks<Dynamic>> {
    return null;
  }
}
