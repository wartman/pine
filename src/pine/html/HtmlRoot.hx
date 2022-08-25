package pine.html;

abstract class HtmlRoot<T> extends RootComponent {
  static final type = new UniqueId();

  final el:T;

  public function new(props:{
    el:T,
    child:Null<Component>
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

  abstract public function createElement():Element;

  override function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    return object;
  }
}

class HtmlRootElement<T> extends RootElement {
  public function createPlaceholder():Component {
    return new HtmlTextComponent({content: ''});
  }
}
