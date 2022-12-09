package pine.element;

import haxe.ds.Option;
import pine.core.Disposable;
import pine.adapter.Adapter;

interface AncestorManager extends Disposable {
  public function update(parent:Null<Element>):Void;
  public function getParent():Option<Element>;
  public function getQuery():AncestorQuery;
}