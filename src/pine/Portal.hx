package pine;

import kit.Assert;

class Portal extends Component {
  final target:Dynamic;
  final build:()->Component;

  var marker:Null<Component> = null;
  var portalRoot:Null<Root> = null;

  public function new(target, build) {
    this.target = target;
    this.build = build;
  }

	public function getObject():Dynamic {
    assert(marker != null);
    return marker.getObject();
	}

	public function initialize() {
    assert(marker == null);

    marker = new Placeholder();
    marker.mount(this, slot);

    switch status {
      case Initializing(Hydrating(_)):
        portalRoot = new Root(target, build, getAdaptor());
        portalRoot.hydrate(null, getAdaptor().createCursor(target));
      default:
        portalRoot = new Root(target, build, getAdaptor());
        portalRoot.mount();
    }
  }

	public function visitChildren(visitor:(child:Component) -> Bool) {
    if (portalRoot != null) portalRoot.visitChildren(visitor);
  }

  override function updateSlot(?newSlot:Slot) {
    super.updateSlot(newSlot);
    assert(marker != null);  
    marker.updateSlot(newSlot);
  }

  override function dispose() {
    super.dispose();
    if (marker != null) {
      marker.dispose();
      marker = null;
    }
    if (portalRoot != null) {
      portalRoot.dispose();
      portalRoot = null;
    }
  }
}
