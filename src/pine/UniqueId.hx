package pine;

@:forward
abstract UniqueId(Int) to Int {
  static var uid:Int = 0;

  inline public function new() {
    this = uid++;
  }

  @:to
  public function toString():String {
    return this + '';
  }
}
