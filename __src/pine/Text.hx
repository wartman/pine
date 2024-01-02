package pine;

import pine.debug.Debug;
import pine.internal.ObjectHost;
import pine.internal.Slot;
import pine.signal.Computation;
import pine.signal.Observer;
import pine.signal.Signal;

abstract Text(TextComponent) to TextComponent to Component to Child {
  @:from public inline static function ofString(content:String) {
    return new Text(content);
  }

  @:from public inline static function ofInt(content:Int) {
    return new Text(content + '');
  }

  @:from public inline static function ofFloat(content:Float) {
    return new Text(content + '');
  }

  @:from public inline static function ofStringReadonlySignal(content:ReadonlySignal<String>) {
    return new Text(content);
  }

  @:from public inline static function ofIntReadonlySignal(content:ReadonlySignal<Int>) {
    return new Text(new Computation(() -> content() + ''));
  }

  @:from public inline static function ofFloatReadonlySignal(content:ReadonlySignal<Float>) {
    return new Text(new Computation(() -> content() + ''));
  }

  @:from public inline static function ofStringSignal(content:Signal<String>) {
    return new Text(content);
  }

  @:from public inline static function ofIntSignal(content:Signal<Int>) {
    return new Text(new Computation(() -> content() + ''));
  }

  @:from public inline static function ofFloatSignal(content:Signal<Float>) {
    return new Text(new Computation(() -> content() + ''));
  }

  public inline function new(content:ReadonlySignal<String>) {
    this = new TextComponent(content);
  }
}

class TextComponent extends Component implements ObjectHost {
  final content:ReadonlySignal<String>;
  var object:Null<Dynamic> = null;

  public function new(content) {
    this.content = content;
  }

  public function initialize() {
    initializeObject();
    observeContentChanges();
  }

  function initializeObject() {
    var adaptor = getAdaptor();

    switch componentLifecycleStatus {
      case Hydrating(cursor):
        object = cursor.current();
        cursor.next();
      default:
        object = adaptor.createTextObject(content.peek());
        adaptor.insertObject(object, slot, findNearestObjectHostAncestor);
    }
  }

  function observeContentChanges() {
    Observer.track(() -> {
      var text = content();
      switch componentLifecycleStatus {
        case Mounting | Hydrating(_):
        default:
          getAdaptor().updateTextObject(getObject(), text);
      }
    });
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {}

  public function getObject():Dynamic {
    assert(object != null);
    return object;
  }

  function disposeObject() {
    if (object != null) {
      getAdaptor().removeObject(object, slot);
      object = null;
    }
  }

  override function updateSlot(?newSlot:Slot) {
    if (slot == newSlot) return;
    var prevSlot = slot;
    super.updateSlot(newSlot);
    getAdaptor().moveObject(getObject(), prevSlot, slot, findNearestObjectHostAncestor);
  }

  override function dispose() {
    disposeObject();
    super.dispose();
  }
}
