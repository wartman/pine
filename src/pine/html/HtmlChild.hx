package pine.html;

@:forward
abstract HtmlChild(Component) from Component to Component {
  @:from
  public inline static function ofString(content:String):HtmlChild {
    return new HtmlTextComponent({content: content});
  }

  @:from
  public inline static function ofInt(content:Int):HtmlChild {
    return new HtmlTextComponent({content: content + ''});
  }
}
