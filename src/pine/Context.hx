package pine;

import haxe.ds.Option;
import pine.adapter.Adapter;
import pine.core.DisposableHost;
import pine.element.*;

interface Context extends DisposableHost {
  public function getObject():Dynamic;
  public function getComponent<T:Component>():T;
  public function getAdapter():Option<Adapter>;
  public function queryAncestors():AncestorQuery;
  public function queryChildren():ChildrenQuery;
}
