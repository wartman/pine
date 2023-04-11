package pine;

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

  public inline function new(content) {
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

    switch status {
      case Initializing(Hydrating(cursor)):
        object = cursor.current();
        cursor.next();
      default:
        object = adaptor.createTextObject(content.peek());
        adaptor.insertObject(object, slot, findNearestObjectHostAncestor);
    }

    var observer = new Observer(() -> {
      var text = content.get();
      switch status {
        case Initializing(_):
        default:
          getAdaptor().updateTextObject(getObject(), text);
      }
    });

    addDisposable(observer);
  }

	public function visitChildren(visitor:(child:Component) -> Bool) {}
}
