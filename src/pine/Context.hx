package pine;

interface Context {
  public function get<T>(type:Class<T>):Null<T>;
}
