package pine;

@:forward
abstract TrackedArray<T>(Signal<Array<T>>) {
  @:from
  public inline static function ofArray<T>(items:Array<T>) {
    return new TrackedArray(items);
  }

  @:to
  public inline function toArray() {
    return this.get();
  }

  public var length(get, never):Int;

  public function get_length() {
    return this.get().length;
  }

  public function new(data) {
    this = new Signal(data);
  }

  public function push(item) {
    var index = this.value.push(item);
    this.notify();
    return index;
  }

  public function map<R>(transform):Array<R> {
    return this.get().map(transform);
  }

  public function filter(test) {
    return this.get().filter(test);
  }

  public function clear() {
    this.set([]);
  }

  public function remove(item:T) {
    var result = this.value.remove(item);
    this.notify();
    return result;
  }

  @:op([])
  public function at(index:Int) {
    return this.get()[index];
  }
}
