package pine.element;

import haxe.ds.Option;
import pine.adapter.Adapter;
import pine.core.Disposable;

interface AdapterManager extends Disposable {
  public function get():Option<Adapter>;
  public function update(parent:Null<Element>):Void;
}


