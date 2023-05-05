package pine;

import pine.debug.Debug;
import pine.internal.Slot;
import pine.signal.Observer;
import pine.signal.Signal;

using Kit;

enum SuspenseStatus {
  Suspended(remaining:Array<Task<Any, Any>>);
  Ready;
}

class Suspense extends Component {
  public static function from(context:Component) {
    return maybeFrom(context).orThrow('No Suspense found');
  }

  public static function maybeFrom(context:Component):Maybe<Suspense> {
    return context.findAncestorOfType(Suspense);
  }

  final child:Component;
  final fallback:Null<()->Child>;
  final onComplete:Null<()->Void>;
  final status = new Signal<SuspenseStatus>(Ready);
  var hiddenMarker:Null<Component> = null;
  var currentComponent:Null<Child> = null;

  public function new(props:{
    child:Child,
    ?fallback:()->Child,
    ?onComplete:()->Void
  }) {
    this.child = props.child;
    this.fallback = props.fallback;
    this.onComplete = props.onComplete;
  }

  public function await<T, E>(task:Task<T, E>) {
    switch status.peek() {
      case Suspended(remaining) if (remaining.contains(task)):
        return;
      case Suspended(remaining):
        status.set(Suspended(remaining.concat([task])));
      case Ready:
        status.set(Suspended([task]));
    }
    var link = task.handle(_ -> switch status.peek() {
      case Suspended(remaining) if (remaining.contains(task)):
        var remaining = remaining.filter(o -> o != task);
        if (remaining.length == 0) {
          status.set(Ready);  
        } else {
          status.set(Suspended(remaining));
        }
      default:
    });
    addDisposable(() -> {
      if (link == null) return;
      link.cancel();
      link = null;
    });
  }

	public function getObject():Dynamic {
    if (currentComponent == null) {
      error('No object found');
    } 
    return currentComponent.getObject();
	}

	public function visitChildren(visitor:(child:Component) -> Bool) {
    if (currentComponent != null) visitor(currentComponent);
  }

  override function updateSlot(?newSlot:Slot) {
    super.updateSlot(newSlot);
    if (currentComponent != null) currentComponent.updateSlot(newSlot);
  }

	public function initialize() {
    // @todo: There may be a better way to handle this
    hiddenMarker = new Placeholder();
    var root = new Root(
      adaptor.createEmptyContainerObject(),
      () -> hiddenMarker,
      adaptor
    );
    var hiddenSlot = createSlot(1, hiddenMarker);
    root.mount();
    addDisposable(root);

    // @todo: Need to test hydration here.
    componentBuildStatus = Building;
    switch componentLifecycleStatus {
      case Hydrating(cursor):
        child.hydrate(this, cursor, slot);
        currentComponent = child;
        // @todo: Maybe we have our Resources throw an error
        // during hydration if they suspend? Get closer to the
        // problem that way.
        assert(switch scope.peek() {
          case Ready: true;
          default: false;
        }, 'Components should not suspend during hydration');
      default:
        child.mount(this, hiddenSlot);
    }
    componentBuildStatus = Built;

    Observer.track(() -> {
      assert(componentBuildStatus != Building);
      assert(componentLifecycleStatus != Disposed);

      if (componentLifecycleStatus == Disposing) return;

      componentBuildStatus = Building;
      
      if (fallback == null) {
        currentComponent = child;
        if (currentComponent.slot != slot) {
          currentComponent.updateSlot(slot);
        }
        switch status() {
          case Ready if (onComplete != null): onComplete();
          default: 
        }
        componentBuildStatus = Built;
        return;
      }

      switch status() {
        case Suspended(_) if (currentComponent != null && currentComponent is Placeholder):
          // noop
        case Suspended(_):
          if (currentComponent != null && currentComponent != child) {
            currentComponent.dispose();
          }
          if (currentComponent == child) {
            child.updateSlot(hiddenSlot);
          }
          currentComponent = fallback();
          currentComponent.mount(this, slot);
        case Ready if (isComponentHydrating()):
          // noop
        case Ready:
          if (currentComponent != null && currentComponent != child) {
            currentComponent.dispose();
          }
          currentComponent = child;
          currentComponent.updateSlot(slot);
          if (onComplete != null) onComplete();
      }
  
      componentBuildStatus = Built;
    });
  }

  override function dispose() {
    super.dispose();
    // `child` may not be the `currentComponent` and thus
    // may not be disposed when children are visited. We
    // need to ensure it is removed in that case. 
    if (!child.isComponentDisposed()) {
      child.dispose();
    }
  }
}
