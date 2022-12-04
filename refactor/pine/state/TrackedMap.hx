package pine.state;

import haxe.ds.Map;

@:forward
abstract TrackedMap<K, V>(Atom<Map<K, V>>) {
  @:from
  public inline static function ofMap<K, V>(map:Map<K, V>) {
    return new TrackedMap(map);
  }

  @:to
  public inline function toMap() {
    return this.get();
  }

  public function new(map:Map<K, V>) {
    this = new Atom(map);
  }

  public inline function replace(map:Map<K, V>) {
    this.set(map);
  }

  @:op([])
  public inline function get(key:K):Null<V> {
    return this.get().get(key);
  }

  @:op([])
  public function set(key:K, value:V):Void {
    this.value.set(key, value);
    this.notify();
  }

  public inline function exists(key:K) {
    return this.get().exists(key);
  }

  public function remove(key:K) {
    if (this.value.remove(key)) {
      this.notify();
    }
  }

  public inline function keys() {
    return this.get().keys();
  }

  public inline function iterator():Iterator<V> {
    return this.get().iterator();
  }

  public inline function keyValueIterator():KeyValueIterator<K, V> {
    return this.get().keyValueIterator();
  }

  public inline function toString() {
    return this.get().toString();
  }

  public inline function copy() {
    return this.get().copy();
  }

  public function clear():Void {
    this.value.clear();
    this.notify();
  }
}
