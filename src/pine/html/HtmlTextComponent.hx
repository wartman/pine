package pine.html;

class HtmlTextComponent extends ObjectComponent {
  static public final applicatorType = new UniqueId();
  static final type = new UniqueId();

  public final content:String;

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

  public function getApplicatorType():UniqueId {
    return applicatorType;
  }

  public function createElement():Element {
    return new ObjectWithoutChildrenElement(this);
  }
}
