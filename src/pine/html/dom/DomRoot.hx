package pine.html.dom;

using Type;

// @todo: Probs could merge this with ServerRoot
class DomRoot extends RootComponent {
  static final type = new UniqueId();

  final el:js.html.Element;

  public function new(props:{
    el:js.html.Element,
    child:Component
  }) {
    super(props);
    this.el = props.el;
  }

  public function getApplicatorType():UniqueId {
    return HtmlElementComponent.applicatorType;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function getRootObject():Dynamic {
    return el;
  }

  public function createElement():Element {
    return new DomRootElement(this);
  }

  override function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    return object;
  }
}

class DomRootElement extends RootElement {
  public function new(root) {
    super(root, new ObjectApplicatorCollection([
      HtmlElementComponent.applicatorType => new HtmlElementApplicator(),
      HtmlTextComponent.applicatorType => new HtmlTextApplicator()
    ]));
  }

  public function getDefaultApplicator():ObjectApplicator<ObjectComponent> {
    return cast applicators.get(HtmlElementComponent.applicatorType);
  }

  public function createPlaceholderObject(_:Component):Dynamic {
    return new js.html.Text('');
  }
}
