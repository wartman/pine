package pine.html;

import pine.adaptor.ObjectType;
import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.*;
import pine.element.object.*;
import pine.element.core.NoChildrenManager;

using pine.core.OptionTools;

final class HtmlTextComponent extends ObjectComponent implements HasComponentType {
  public final content:String;

  public function new(props:{
    content:String,
    ?key:Key
  }) {
    super(props.key);
    content = props.content;
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new NoChildrenManager(element);
  }

  function getObjectType():ObjectType {
    return ObjectText;
  }

  public function getObjectData() {
    return content;
  }
}
