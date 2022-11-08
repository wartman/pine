package pine;

import haxe.Exception;

// @todo: This is just a placeholder at the moment, as I'm
// still trying to figure out the best way to implement this.
//
// Usage will be something like:
// ErrorBoundary.from(context).handle(exception);

class ErrorBoundary extends Component {
  public static final componentType = new UniqueId();

  public static function from(context:Context) {
    return switch context.findAncestorOfType(ErrorBoundaryElement) {
      case Some(element): element;
      case None: throw new PineException('No error boundary was found');
    }
  }

  public static function maybeFrom(context:Context) {
    return context.findAncestorOfType(ErrorBoundaryElement);
  }

  final child:Component;
  final catchError:(e:Exception)->Component;

  public function new(props:{
    child:Component,
    catchError:(e:Exception)->Component,
    ?key:Key
  }) {
    super(props.key);
    this.child = props.child;
    this.catchError = props.catchError;    
  }

  public function getComponentType():UniqueId {
    return componentType;
  }

  public function createElement():Element {
    return new ErrorBoundaryElement(this);
  }
}

@component(ErrorBoundary)
class ErrorBoundaryElement extends Element {
  public function handle(e:Exception) {
    // todo
  }

  function performHydrate(cursor:HydrationCursor) {}

  function performBuild(previousComponent:Null<Component>) {}

  function performDispose() {}

  public function visitChildren(visitor:ElementVisitor) {}
}
