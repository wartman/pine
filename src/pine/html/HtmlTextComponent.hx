package pine.html;

class HtmlTextComponent extends ObjectComponent {
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

  override function getApplicator(context:Context):ObjectApplicator<Dynamic> {
    return Adapter.from(context).getTextApplicator(this);
  }

  public function createElement():Element {
    return new ObjectWithoutChildrenElement(this);
  }
}
