package pine.debug;

import haxe.Exception;
import pine.core.*;
import pine.diffing.Key;
import pine.element.ProxyElementEngine;

enum BoundaryStatus {
  Ok;
  Failed(exception:Exception);
}

// @todo: This implementation is currently more than a little questionable.

@:allow(pine.debug)
class Boundary extends Component implements HasComponentType {
  public static function from(context:Context) {
    return switch BoundaryContextProvider.maybeFrom(context) {
      case Some(boundary): boundary;
      case None: GlobalBoundaryContext.getInstance();
    }
  }

  final render:(context:Context)->Component;
  final caught:(exception:Exception)->Component;
  #if debug
  var status:BoundaryStatus = Ok;
  #end

  public function new(props:{
    render:(context:Context)->Component,
    caught:(exception:Exception)->Component,
    ?key:Key
  }) {
    super(props.key);
    this.render = props.render;
    this.caught = props.caught;
  }

  public function createElement():Element {
    return new Element(
      this,
      #if debug
      useProxyElementEngine((element:ElementOf<Boundary>) -> {
        return new BoundaryContextProvider({
          create: () -> new ScopedBoundaryContext(element),
          dispose: boundary -> boundary.dispose(),
          render: boundary -> switch element.component.status {
            case Ok:
              try {
                element.component.render(element);
              } catch (e) {
                element.component.status = Failed(e);
                element.invalidate();
                new Fragment({ children: [] });  
              }
            case Failed(exception):
              status = Ok;
              element.component.caught(exception);
          }
        });
      }),
      #else
      useProxyElementEngine((element:ElementOf<Boundary>) -> element.component.render(element)),
      #end
      []
    );
  }
}

typedef BoundaryContextProvider = Provider<BoundaryContext>;

@:allow(pine.debug)
abstract class BoundaryContext implements Disposable {
  public function new() {}

  abstract public function catchException(e:Exception):Void;

  abstract public function exceptionWasCaught():Bool;

  public function dispose() {}
}


@:allow(pine.debug)
class ScopedBoundaryContext extends BoundaryContext {
  final element:ElementOf<Boundary>;

  public function new(element) {
    super();
    this.element = element;
  }

  public function catchException(e:Exception) {
    #if debug
    // @todo: Mutating the component like this seems iffy. Is there
    // a more idiomatic way to do this? Or is this OK?
    element.component.status = Failed(e);
    element.invalidate();
    #else
    throw e;
    #end
  }

  public function exceptionWasCaught():Bool {
    return element.component.status != Ok;
  }
}

class GlobalBoundaryContext extends BoundaryContext {
  static var instance:Null<GlobalBoundaryContext> = null;

  public static function getInstance():GlobalBoundaryContext {
    if (instance == null) {
      instance = new GlobalBoundaryContext();
    }
    return instance;
  }

  function catchException(e:Exception) {
    throw e;
  }

  public function exceptionWasCaught():Bool {
    return false;
  }
}
