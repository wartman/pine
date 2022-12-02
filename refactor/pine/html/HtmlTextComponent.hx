package pine.html;

import pine.adapter.*;
import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.*;
import pine.element.core.NoChildrenManager;

final class HtmlTextComponent extends ObjectComponent implements HasComponentType {
  public final content:String;

  public function new(props:{
    content:String,
    ?key:Key
  }) {
    super(props.key);
    content = props.content;
  }

  override function getApplicatorFrom(adapter:Adapter):ObjectApplicator<Dynamic> {
    return adapter.getTextApplicator(this);
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new NoChildrenManager(element);
  }

  function createLifecycleHooks():Null<LifecycleHooks<Dynamic>> {
    return null;
  }
}
