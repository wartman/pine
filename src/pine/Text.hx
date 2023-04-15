package pine;

import pine.signal.Computation;
import pine.signal.Signal;
import pine.signal.Observer;

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

class TextComponent extends ObjectComponent {
  final content:ReadonlySignal<String>;

  public function new(content) {
    this.content = content;
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

    Observer.track(() -> {
      var text = content.get();
      switch componentLifecycleStatus {
        case Mounting | Hydrating(_):
        default:
          getAdaptor().updateTextObject(getObject(), text);
      }
    });
  }

	public function visitChildren(visitor:(child:Component) -> Bool) {}
}
