package pine;

import pine.signal.Computation;
import pine.signal.Observer;
import pine.signal.Signal;

@:forward
abstract Text(TextView) to View to Child {
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
    this = new TextView(content);
  }
}

class TextView extends View {
  final content:ReadOnlySignal<String>;
  
  var primitive:Null<Dynamic> = null;
  var link:Null<Disposable> = null;

  public function new(content) {
    this.content = content;
  }

  function __initialize() {
    var adaptor = getAdaptor();
    var parent = ensureParent();

    primitive = adaptor.createTextPrimitive(content.peek(), slot, parent.findNearestPrimitive);
    link = new Observer(() -> adaptor.updateTextPrimitive(primitive, content()));

    adaptor.insertPrimitive(primitive, slot, parent.findNearestPrimitive);
  }

  public function findNearestPrimitive():Dynamic {
    return primitive;
  }

  public function getPrimitive():Dynamic {
    return primitive;
  }

  function __updateSlot(prevSlot:Null<Slot>, newSlot:Null<Slot>) {
    var adaptor = getAdaptor();
    var parent = ensureParent();

    adaptor.movePrimitive(primitive, prevSlot, newSlot, parent.findNearestPrimitive);
  }

  function __dispose() {
    var adaptor = getAdaptor();

    link?.dispose();
    link = null;
    adaptor.removePrimitive(primitive, slot);
  }
}
