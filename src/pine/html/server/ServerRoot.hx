package pine.html.server;

import pine.render.Object;

// @todo: Probs could merge this with DomRoot
class ServerRoot extends RootComponent {
  static final type = new UniqueId();

  final el:Object;

  public function new(props:{
    el:Object,
    child:Component
  }) {
    super(props);
    this.el = props.el;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function createElement():Element {
    return new ServerRootElement(this);
  }

  override function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    return object;
  }

  public function getRootObject():Dynamic {
    return el;
  }

  public function getApplicatorType():UniqueId {
    return HtmlElementComponent.applicatorType;
  }
}

class ServerRootElement extends RootElement {
  public function new(root) {
    super(root, new ObjectApplicatorCollection([
      HtmlElementComponent.applicatorType => new HtmlElementApplicator(),
      HtmlTextComponent.applicatorType => new HtmlTextApplicator()
    ]));
  }

  public function getDefaultApplicator():ObjectApplicator<ObjectComponent> {
    return cast applicators.get(HtmlElementComponent.applicatorType);
  }

  public function createPlaceholderObject(component:Component):Dynamic {
    return new HtmlTextObject('');
  }
}
