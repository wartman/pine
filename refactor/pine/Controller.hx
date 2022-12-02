package pine;

import pine.core.Disposable;

interface Controller<T:Component> extends Disposable {
  public function register(element:ElementOf<T>):Void;
}
