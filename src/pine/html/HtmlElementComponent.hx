package pine.html;

class HtmlElementComponent<Attrs:{}> extends ObjectComponent {
  static final types:Map<String, UniqueId> = [];

  public static function getTypeForTag(tag:String):UniqueId {
    var type = types.get(tag);
    if (type == null) {
      type = new UniqueId();
      types.set(tag, type);
    }
    return type;
  }

  final tag:String;
  final attrs:Attrs;
  final type:UniqueId;
  final isSvg:Bool;
  final children:Null<Array<Component>>;

  public function new(props:{
    tag:String,
    attrs:Attrs,
    ?isSvg:Bool,
    ?children:Array<Component>,
    ?key:Key
  }) {
    super(props.key);
    tag = props.tag;
    type = getTypeForTag(props.tag);
    attrs = props.attrs;
    isSvg = props.isSvg == null ? false : props.isSvg;
    children = props.children;
  }

  public function getChildren() {
    return children == null ? [] : children;
  }

  public function getComponentType() {
    return type;
  }

  public function createObject(root:Root):Dynamic {
    Debug.assert(root is HtmlRoot, 'HtmlElementComponent can only be used with a pine.Root that implements pine.html.HtmlRoot.');
    var html:HtmlRoot = cast root;
    var object = html.createHtmlElement(tag, attrs, isSvg);
    return object;
  }

  public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    Debug.assert(root is HtmlRoot, 'HtmlElementComponent can only be used with a pine.Root that implements pine.html.HtmlRoot.');
    var html:HtmlRoot = cast root;
    var prev:Null<HtmlElementComponent<Attrs>> = cast previousComponent;
    html.updateHtmlElement(object, attrs, prev != null ? prev.attrs : null);
    return object;
  }

  public function createElement():Element {
    return new ObjectWithChildrenElement(this);
  }
}
