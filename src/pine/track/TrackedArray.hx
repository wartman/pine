package pine.track;

@:forward
abstract TrackedArray<T>(Signal<Array<T>>) {
  @:from
  public static function ofArray<T>(items:Array<T>) {
    return new TrackedArray(items);
  }

  public var length(get, never):Int;

  public function get_length() {
    return this.get().length;
  }

  public function new(data) {
    this = new Signal(data);
  }

  public function push(item) {
    merge([item]);
  }

  public function merge(items:Array<T>) {
    this.set(this.value.concat(items));
  }

  public function remove(item:T) {
    this.set(this.value.filter(i -> i != item));
  }

  @:op([])
  public function at(index:Int) {
    return this.get()[index];
  }
}
