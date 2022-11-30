package pine;

import haxe.ds.Option;
import pine.core.DisposableHost;
import pine.element.*;

interface Context extends DisposableHost {
  public function getObject():Dynamic;
  public function getComponent<T:Component>():T;
  public function getRoot():Option<Root>;
  public function queryAncestors():AncestorQuery;
  public function queryChildren():ChildrenQuery;
}
