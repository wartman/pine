package pine;

class TrackingTools {
  @:noUsing
  public static function track(handler) {
    return new Observer(handler);
  }

  @:noUsing
  public static function peek(handler) {
    return new Observer(handler, true);
  }

  public inline static function createSignal<T>(value, ?comp):Signal<T> {
    return new Signal(value, comp);
  }
}
