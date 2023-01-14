package pine;

import pine.Element;
import pine.adaptor.Adaptor;
import pine.core.*;
import pine.debug.Debug;
import pine.diffing.Engine;
import pine.diffing.Key;
import pine.element.*;
import pine.element.ElementEngine;
import pine.element.ProxyElementEngine;
import pine.hydration.Cursor;

using pine.core.OptionTools;

class ErrorBoundary extends Component implements HasComponentType {
  public final render:(context:Context)->Component;
  public final fallback:Null<(e:ThrownObject)->Component>;
  public final recover:Null<(e:ThrownObject, next:()->Void)->Void>;

  public function new(props:{
    render:(context:Context)->Component,
    ?fallback:(thrown:ThrownObject)->Component,
    ?recover:(thrown:ThrownObject, next:()->Void)->Void,
    ?key:Key
  }) {
    super(props.key);
    this.render = props.render;
    this.fallback = props.fallback;
    this.recover = props.recover;
  }

  public function createElement():Element {
    return new Element(
      this,
      element -> new ErrorBoundaryEngine(element),
      []
    );
  }
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

enum ErrorBoundaryStatus {
  Pending;
  Ok(child:Null<Element>);
  Failed(error:ThrownObject, failedBranch:Element, fallback:Null<Element>);
}

class ErrorBoundaryEngine implements ElementEngine {
  final element:ElementOf<ErrorBoundary>;
  var status:ErrorBoundaryStatus = Pending;

  public function new(element) {
    this.element = element;
  }

  // @todo: I think this implementation has the risk of leading
  // to all kinds of race conditions.
  public function handleError(target:Element, e:Dynamic) {
    Debug.assert(element != target);

    var thrown:ThrownObject = { object: e, element: target };
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
    var recover = element.component.recover;
    var fallback = element.component.fallback;
    var errBranch = fallback != null ? {
      var comp = fallback(thrown);
      if (comp == null) comp = new Fragment({ children: [] });
      comp.createElement();
    } : new Fragment({ children: [] }).createElement();

    failedBranch.updateSlot(null); // should remove the object from the concrete tree
    status = Failed(thrown, failedBranch, errBranch);
    errBranch.mount(element, element.slot);

    if (recover != null) {
      recover(thrown, () -> {
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
    var fallback = element.component.fallback;
    var comp = switch status {
      case Pending | Ok(_):
        element.component.render(element);
      case Failed(thrown, _, _) if (fallback != null):
        fallback(thrown);
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
