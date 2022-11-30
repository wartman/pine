package pine.element.core;

import haxe.ds.Option;

class CoreAncestorManager implements AncestorManager {
  final element:Element;
  
  var parent:Null<Element> = null;
  var root:Null<Root> = null;
  var query:Null<AncestorQuery> = null;

  public function new(element) {
    this.element = element;
  }

  public function update(parent:Null<Element>) {
    this.parent = parent;
    if (parent != null) switch parent.ancestors.getRoot() {
      case Some(root): this.root = root;
      case None:
    }
  }

  public function getParent():Option<Element> {
    return if (parent == null) None else Some(parent);
  }

  public function getRoot():Option<Root> {
    return if (root == null) None else Some(root);
  }

	public function getQuery():AncestorQuery {
    if (query == null) query = new CoreAncestorQuery(element);
    return query;
	}
  
  public function dispose() {
    parent = null;
    root = null;
    query = null;
  }
}
