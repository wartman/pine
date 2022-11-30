package pine.element.root;

import haxe.ds.Option;
import pine.element.core.CoreAncestorQuery;

class RootAncestorManager implements AncestorManager {
  final element:Element;
  final root:Root;

  var parent:Null<Element> = null;
  var query:Null<AncestorQuery> = null;

  public function new(element, root) {
    this.element = element;
    this.root = root;
  }

  public function update(parent:Null<Element>) {
    this.parent = parent;
  }

  public function getParent():Option<Element> {
    return if (parent == null) None else Some(parent);
  }

  public function getRoot():Option<Root> {
    return Some(root);
  }

	public function getQuery():AncestorQuery {
    if (query == null) query = new CoreAncestorQuery(element);
    return query;
	}
  
  public function dispose() {
    parent = null;
  }
}
