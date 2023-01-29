package pine.html;

import pine.adaptor.ObjectType;
import pine.core.HasComponentType;
import pine.diffing.Key;

using pine.core.OptionTools;

@:deprecated('Use pine.Text')
final class HtmlTextComponent extends ObjectComponent implements HasComponentType {
  public final content:String;

  public function new(props:{
    content:String,
    ?key:Key
  }) {
    super(props.key);
    content = props.content;
  }

  function getObjectType():ObjectType {
    return ObjectText;
  }

  public function getObjectData() {
    return content;
  }

  public function render() {
    return [];
  }
}
