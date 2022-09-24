package pine;

class ObserverElement extends Element {
  final child:SingleChild;

  var isInitialized:Bool = false;
  var trackedObject:Null<Dynamic> = null;
  var computedRender:Null<Computation<Component>> = null;
  
  var observerComponent(get, never):ObserverComponent;
  inline function get_observerComponent():ObserverComponent {
    return getComponent();
  }

  public function new(component:ObserverComponent) {
    super(component);
    child = new SingleChild(render, new ElementFactory(this));
  }

  function performHydrate(cursor:HydrationCursor) {
    trackedObject = observerComponent.createTrackedObject();
    initialize();
    child.hydrate(cursor, slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null || trackedObject == null) {
      trackedObject = observerComponent.createTrackedObject();
    } else if (previousComponent != component) {
      observerComponent.reuseTrackedObject(trackedObject);
    }

    if (!isInitialized) initialize();

    child.update(previousComponent, slot);
  }
  
  function performUpdateSlot(?slot:Slot) {
    child.update(slot); 
  }

  function createRenderComputation() {
    Debug.assert(computedRender == null);
    Debug.assert(status == Building, '`createRenderComputation` should ONLY be called from `performHydrate` or `performBuild`');
    
    return new Computation(() -> {
      var result = observerComponent.render(this);
      if (status != Building) invalidate();
      return result;
    });
  }

  function render() {
    if (computedRender == null) {
      computedRender = createRenderComputation();
    }
    return computedRender.get();
  }

  function initialize() {
    Debug.assert(!isInitialized);
    isInitialized = true;
    observerComponent.init(this);
  }

  function performDispose() {
    if (computedRender != null) {
      computedRender.dispose();
      computedRender = null;
    }
    child.dispose();
  }

  public function visitChildren(visitor:ElementVisitor) {
    child.visit(visitor);
  }
}
