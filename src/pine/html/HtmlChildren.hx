package pine.html;

abstract HtmlChildren(Array<HtmlChild>) from Array<HtmlChild> to Array<HtmlChild> {
  @:from
  public inline static function ofComponent(child:Component):HtmlChildren {
    return [ child ];
  }

  @:from
  public inline static function ofString(content:String):HtmlChildren {
    return [ new HtmlTextComponent({content: content}) ];
  }
}
