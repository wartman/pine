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
  function get_length() return this.get().length;

  public function new(data) {
    this = new Signal(data);
  }

  public inline function replace(items) {
    this.set(items);
  }

  public function push(item) {
    var index = this.value.push(item);
    this.notify();
    return index;
  }

  public function unshift(item:T):Void {
    this.value.unshift(item);
    this.notify();
  }

  public inline function map<R>(transform):Array<R> {
    return this.get().map(transform);
  }

  public inline function filter(test) {
    return this.get().filter(test);
  }

  public inline function clear() {
    this.set([]);
  }

  public inline function join(sep:String) {
    return this.get().join(sep);
  }

  public function concat(a:Array<T>):Array<T> {
    this.set(this.value.concat(a));
    return this.value;
  }

  public function pop():Null<T> {
    var item = this.value.pop();
    this.notify();
    return item;
  }

  public function reverse():Void {
    this.value.reverse();
    this.notify();
  }

  public function shift():Null<T> {
    var item = this.value.shift();
    this.notify();
    return item;
  }

  public function slice(pos:Int, ?end:Int):Array<T> {
    return this.get().slice(pos, end);
  }

  public function sort(f):Void {
    this.value.sort(f);
    this.notify();
  }

  public function splice(pos:Int, len:Int):Array<T> {
    return this.get().splice(pos, len);
  }

  public function toString():String {
    return this.get().toString();
  }

  public function resize(len:Int) {
    this.value.resize(len);
    this.notify();
  }

  public function indexOf(item:T, ?fromIndex:Int) {
    return this.get().indexOf(item, fromIndex);
  }

  public function lastIndexOf(item:T, ?fromIndex:Int) {
    return this.get().lastIndexOf(item, fromIndex);
  }
  
  public function remove(item:T) {
    var result = this.value.remove(item);
    this.notify();
    return result;
  }

  @:op([])
  public inline function at(index:Int) {
    return this.get()[index];
  }

  @:op([])
  public function set(index:Int, value:T) {
    this.value[index] = value;
    this.notify();
  }
}
