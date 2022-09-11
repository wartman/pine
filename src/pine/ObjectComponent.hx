package pine;

abstract class ObjectComponent extends Component {
  abstract public function getChildren():Array<Null<Component>>;
  
  public function getApplicator(context:Context):ObjectApplicator<Dynamic> {
    return Adapter.from(context).getApplicator(this);
  }
}
