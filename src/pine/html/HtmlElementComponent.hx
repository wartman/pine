package pine.html;

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

  public function getChildren() {
    return children == null ? [] : children;
  }

  public function createElement():Element {
    return new ObjectWithChildrenElement(this);
  }
}
