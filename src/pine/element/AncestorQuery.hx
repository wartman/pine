package pine.element;

import haxe.ds.Option;

final class AncestorQuery {
  final element:Element;
  
  public function new(element) {
    this.element = element;
  }

  public function ofType<T:Component>(kind:Class<T>):Option<ElementOf<T>> {
    return switch element.getParent() {
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
    return switch element.getParent() {
      case Some(parent) if (match(parent)): Some(parent);
      case Some(parent): parent.queryAncestors().find(match);
      case None: None;
    }
  }
}
