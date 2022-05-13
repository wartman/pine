package pine.html;

interface HtmlRoot extends Root {
  public function createHtmlElement<Attrs:{}>(tag:String, attrs:Attrs, isSvg:Bool):Dynamic;
  public function updateHtmlElement<Attrs:{}>(object:Dynamic, newAttrs:Attrs, ?oldAttrs:Attrs):Void;
  public function createHtmlText(content:String):Dynamic;
  public function updateHtmlText(object:Dynamic, content:String, ?previous:String):Void;
}
