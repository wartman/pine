package pine.element.core;

import haxe.ds.Option;
import pine.core.HasLazyProps;

class CoreAncestorManager 
  implements AncestorManager 
  implements HasLazyProps
{
  final element:Element;
  
  var parent:Null<Element> = null;
  @lazy var query:AncestorQuery = new CoreAncestorQuery(element);

  public function new(element) {
    this.element = element;
  }

  public function update(parent:Null<Element>) {
    this.parent = parent;
  }

  public function getParent():Option<Element> {
    return if (parent == null) None else Some(parent);
  }

	public function getQuery():AncestorQuery {
    return query;
	}
  
  public function dispose() {
    parent = null;
  }
}
