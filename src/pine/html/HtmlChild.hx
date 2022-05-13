package pine.html;

import pine.Component;

@:forward
abstract HtmlChild(Component) from Component to Component {
  @:from
  public inline static function ofString(content:String):HtmlChild {
    return new HtmlTextComponent({content: content});
  }
}
