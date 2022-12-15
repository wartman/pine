package pine;

abstract HookCollection<T:Component>(Array<Hook<T>>) from Array<Hook<T>> {
  inline public function new(hooks) {
    this = hooks;
  }

  @:to inline public function toHook():Hook<T> {
    return element -> init(element);
  }

  inline public function init(element:Element) {
    for (hook in this) hook(element);
  }
}
