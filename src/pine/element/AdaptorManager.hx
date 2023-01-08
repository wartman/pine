package pine.element;

import haxe.ds.Option;
import pine.adaptor.Adaptor;
import pine.core.Disposable;

interface AdaptorManager extends Disposable {
  public function get():Option<Adaptor>;
  public function update(parent:Null<Element>):Void;
}


