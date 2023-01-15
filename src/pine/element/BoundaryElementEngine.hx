package pine.element;

import pine.Component;
import pine.adaptor.Adaptor;
import pine.debug.Debug;
import pine.diffing.Engine;
import pine.element.*;
import pine.element.ElementEngine;
import pine.element.ProxyElementEngine;
import pine.hydration.Cursor;

function useBoundaryElementEngine(render, options):CreateElementEngine {
  return element -> new BoundaryElementEngine(element, render, options);
}

typedef ThrownObject = {
  /**
    The object that was thrown.
  **/ 
  public final object:Dynamic;
  
  /**
    The element that threw the object.
  **/
  public final element:Element;
} 

enum BoundaryStatus {
  Pending;
  Ok(child:Null<Element>);
  Failed(error:ThrownObject, failedBranch:Element, fallback:Null<Element>);
}

typedef BoundaryElementEngineOptions<T:Component> = {
  public final ?shouldHandle:(element:ElementOf<T>, object:Dynamic)->Bool;
  public final ?fallback:(element:ElementOf<T>, thrown:ThrownObject)->Component;
  public final ?recover:(element:ElementOf<T>, thrown:ThrownObject, next:()->Void)->Void;
} 

class BoundaryElementEngine<T:Component> implements ElementEngine {
  final element:Element;
  final render:(element:ElementOf<T>)->Component;
  final shouldHandle:Null<(element:ElementOf<T>, object:Dynamic)->Bool>;
  final fallback:Null<(element:ElementOf<T>, thrown:ThrownObject)->Component>;
  final recover:Null<(element:ElementOf<T>, thrown:ThrownObject, next:()->Void)->Void>;
  
  var status:BoundaryStatus = Pending;

  public function new(element, render, options:BoundaryElementEngineOptions<T>) {
    this.element = element;
    this.render = render;
    this.shouldHandle = options.shouldHandle;
    this.fallback = options.fallback;
    this.recover = options.recover;
  }

  // @todo: I think this implementation has the risk of leading
  // to all kinds of race conditions.
  public function handleThrownObject(target:Element, object:Dynamic) {
    Debug.assert(element != target);

    if (shouldHandle != null && !shouldHandle(element, object)) {
      bubbleThrownObjectUp(element, target, object);
      return;
    }

    var thrown:ThrownObject = { object: object, element: target };
    var failedBranch:Element = switch status {
      case Ok(child) if (child != null): 
        child;
      case Failed(_, failedBranch, errBranch):
        // @todo: If this happens, should we just give up?
        if (errBranch != null) errBranch.dispose();
        failedBranch;
      default: 
        // @todo: Just bubble up to the next boundary?
        throw 'Could not recover';
    }
    var errBranch = fallback != null ? {
      var comp = fallback(element, thrown);
      if (comp == null) comp = new Fragment({ children: [] });
      comp.createElement();
    } : new Fragment({ children: [] }).createElement();

    failedBranch.updateSlot(null); // should remove the object from the concrete tree
    status = Failed(thrown, failedBranch, errBranch);
    errBranch.mount(element, element.slot);

    if (recover != null) {
      recover(element, thrown, () -> {
        target.recover();
        status = Ok(failedBranch);
        if (errBranch != null) errBranch.dispose();
        failedBranch.updateSlot(element.slot);
        failedBranch.rebuild(); // @todo or should we invalidate? 
      });
    }
  }

  public function init() {
    var child = renderSafe().createElement();
    status = Ok(child);
    child.mount(element, element.slot);
  }

  public function hydrate(cursor:Cursor) {
    var child = renderSafe().createElement();
    status = Ok(child);
    child.hydrate(cursor, element, element.slot);
  }

  public function update() {
    switch status {
      case Pending: throw 'Could not render';
      case Ok(prev):
        var child = updateChild(element, prev, renderSafe(), element.slot);
        status = Ok(child);
      case Failed(error, failedBranch, fallback):
        var child = updateChild(element, fallback, renderSafe(), element.slot);
        status = Failed(error, failedBranch, child);
    }
  }

  public function getAdaptor():Adaptor {
    return findParentAdaptor(element);
  }

  public function getObject():Dynamic {
    return findChildObject(element);
  }

  public function createSlot(index:Int, previous:Null<Element>):Slot {
    return new Slot(index, previous);
  }

  public function updateSlot(slot:Null<Slot>) {
    element.slot = slot;
    visitChildren(child -> {
      child.updateSlot(slot);
      true;
    });
  }

  public function visitChildren(visitor:(child:Element) -> Bool) {
    switch status {
      case Ok(child) if (child != null) : visitor(child);
      case Failed(_, _, fallback) if (fallback != null): visitor(fallback);
      default:
    }
  }

  public function createChildrenQuery():ChildrenQuery {
    return new ChildrenQuery(element);
  }

  public function createAncestorQuery():AncestorQuery {
    return new AncestorQuery(element);
  }

  function renderSafe():Component {
    var comp = switch status {
      case Pending | Ok(_):
        render(element);
      case Failed(thrown, _, _) if (fallback != null):
        fallback(element, thrown);
      default:
        null;
    }
    if (comp == null) return new Fragment({ children: [] });
    return comp;
  }

  public function dispose() {
    switch status {
      case Ok(child) if (child != null):
        child.dispose();
      case Failed(_, failedBranch, fallback):
        failedBranch.dispose();
        if (fallback != null) fallback.dispose();
      default:
    }
    status = Pending;
  }
}
