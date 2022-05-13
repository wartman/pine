package pine;

abstract class RootComponent extends Component {
  public final child:Null<Component>;
  public final scheduler:Scheduler;

  public function new(props:{
    ?scheduler:Scheduler,
    ?child:Component
  }) {
    super(null);
    scheduler = props.scheduler == null ? DefaultScheduler.getInstance() : props.scheduler;
    child = props.child;
  }

  abstract public function getRootObject():Dynamic;
}
