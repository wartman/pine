package pine.html;

class HtmlTextComponent extends ObjectComponent {
  static final type = new UniqueId();

  final content:String;

  public function new(props:{
    content:String,
    ?key:Key
  }) {
    super(props.key);
    content = props.content;
  }

  public function getChildren():Array<Component> {
    return [];
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function createObject(root:Root):Dynamic {
    Debug.assert(root is HtmlRoot, 'HtmlTextComponent can only be used with a pine.Root that implements pine.html.HtmlRoot.');
    var html:HtmlRoot = cast root;
    return html.createHtmlText(content);
  }

  public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    Debug.assert(root is HtmlRoot, 'HtmlTextComponent can only be used with a pine.Root that implements pine.html.HtmlRoot.');
    var html:HtmlRoot = cast root;
    var prev:Null<HtmlTextComponent> = cast previousComponent;
    html.updateHtmlText(object, content, prev != null ? prev.content : null);
    return object;
  }

  public function createElement():Element {
    return new ObjectWithoutChildrenElement(this);
  }
}
