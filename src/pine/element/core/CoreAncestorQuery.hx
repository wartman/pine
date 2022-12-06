package pine.element.core;

import haxe.ds.Option;

class CoreAncestorQuery implements AncestorQuery {
  final element:Element;
  
  public function new(element) {
    this.element = element;
  }

  public function ofType<T:Component>(kind:Class<T>):Option<ElementOf<T>> {
    return switch element.ancestors.getParent() {
      case None if (Std.isOfType(element.component, kind)): 
        Some(element);
      case None: 
        None;
      case Some(parent) if (Std.isOfType(parent.component, kind)):
        Some(parent);
      case Some(parent):
        parent.queryAncestors().ofType(kind);
    }
  }

  public function find(match:(element:Element) -> Bool):Option<Element> {
    if (match(element)) return Some(element);
    return switch element.ancestors.getParent() {
      case Some(parent) if (match(parent)): Some(parent);
      case Some(parent): parent.queryAncestors().find(match);
      case None: None;
    }
  }
}
