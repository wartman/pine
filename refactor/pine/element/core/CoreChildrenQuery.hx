package pine.element.core;

import haxe.ds.Option;

class CoreChildrenQuery implements ChildrenQuery {
  final element:Element;

  public function new(element) {
    this.element = element;
  }

  public function filter(match:(child:Element) -> Bool, recursive:Bool = false):Array<Element> {
    var results:Array<Element> = [];
    
    element.visitChildren(child -> {
      if (match(child)) results.push(child);
      
      if (recursive) {
        results = results.concat(child.queryChildren().filter(match, true));
      }

      true;
    });

    return results;
  }

  public function find(match:(child:Element) -> Bool, recursive:Bool = false):Option<Element> {
    var result:Element = null;

    element.visitChildren(child -> {
      if (match(child)) {
        result = child;
        return false;
      }
      true;
    });

    return switch result {
      case null if (recursive):
        element.visitChildren(child -> switch child.queryChildren().find(match, true) {
          case Some(value):
            result = value;
            false;
          case None:
            true;
        });
        if (result == null) None else Some(result);
      case null: 
        None;
      default: 
        Some(result);
    }
  }

  // public function filterOfType<T:Element>(kind:Class<T>, recursive:Bool = false):Array<T> {
  //   return cast filter(child -> Std.isOfType(child, kind), recursive);
  // }

  public function filterOfType<T:Component>(kind:Class<T>, recursive:Bool = false):Array<ElementOf<T>> {
    return filter(child -> Std.isOfType(child.component, kind), recursive);
  }

  public function findOfType<T:Component>(kind:Class<T>, recursive:Bool = false):Option<ElementOf<T>> {
    return find(child -> Std.isOfType(child.component, kind), recursive);
  }
}
