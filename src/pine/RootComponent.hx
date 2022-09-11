package pine;

abstract class RootComponent extends ObjectComponent {
  public final child:Null<Component>;

  public function new(props:{
    ?child:Component
  }) {
    super(null);
    child = props.child;
  }

  public function getChildren() {
    return [child];
  }

  abstract public function getRootObject():Dynamic;
}
