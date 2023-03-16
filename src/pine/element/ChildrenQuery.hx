package pine.element;

using Kit;

final class ChildrenQuery {
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

  public function find(match:(child:Element) -> Bool, recursive:Bool = false):Maybe<Element> {
    var result:Null<Element> = null;

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

  public function filterOfType<T:Component>(kind:Class<T>, recursive:Bool = false):Array<ElementOf<T>> {
    return filter(child -> Std.isOfType(child.component, kind), recursive);
  }

  public function findOfType<T:Component>(kind:Class<T>, recursive:Bool = false):Maybe<ElementOf<T>> {
    return find(child -> Std.isOfType(child.component, kind), recursive);
  }
}
