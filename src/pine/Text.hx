package pine;

import pine.signal.Computation;
import pine.signal.Observer;
import pine.signal.Signal;

@:forward
abstract Text(TextBuilder) to ViewBuilder to Child {
  public inline static function build(content) {
    return new Text(content);
  }

  @:from public inline static function ofString(content:String) {
    return new Text(content);
  }

  @:from public inline static function ofInt(content:Int) {
    return new Text(content + '');
  }

  @:from public inline static function ofFloat(content:Float) {
    return new Text(content + '');
  }

  @:from public inline static function ofStringReadOnlySignal(content:ReadOnlySignal<String>) {
    return new Text(content);
  }

  @:from public inline static function ofIntReadOnlySignal(content:ReadOnlySignal<Int>) {
    return new Text(new Computation(() -> content() + ''));
  }

  @:from public inline static function ofFloatReadOnlySignal(content:ReadOnlySignal<Float>) {
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

  public inline function new(content:ReadOnlySignal<String>) {
    this = new TextBuilder(content);
  }
}

class TextBuilder implements ViewBuilder {
  final content:ReadOnlySignal<String>;

  public function new(content) {
    this.content = content;
  }

  public function createView(parent:View, slot:Null<Slot>):View {
    return new TextView(parent, parent.adaptor, slot, content);
  }
}

class TextView extends View {
  final content:ReadOnlySignal<String>;
  final primitive:Dynamic;
  final link:Disposable;

  public function new(parent, adaptor, slot, content) {
    super(parent, adaptor, slot);
    this.content = content;
    this.primitive = adaptor.createTextPrimitive(content.peek(), slot, parent.findNearestPrimitive);
    this.link = new Observer(() -> {
      adaptor.updateTextPrimitive(primitive, content());
    });

    adaptor.insertPrimitive(primitive, slot, parent.findNearestPrimitive);
  }

  public function findNearestPrimitive():Dynamic {
    return primitive;
  }

  public function getPrimitive():Dynamic {
    return primitive;
  }

  public function getSlot():Null<Slot> {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {
    var prevSlot = this.slot;
    this.slot = slot;
    adaptor.movePrimitive(primitive, prevSlot, slot, parent.findNearestPrimitive);
  }

  public function dispose() {
    link.dispose();
    adaptor.removePrimitive(primitive, slot);
  }
}
