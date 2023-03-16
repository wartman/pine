package pine;

import pine.adaptor.Adaptor;
import pine.core.HasComponentType;
import pine.debug.Debug;
import pine.diffing.Engine;
import pine.diffing.Key;
import pine.element.*;
import pine.element.ProxyElementEngine;
import pine.hydration.Cursor;

using Kit;

final class Fragment extends Component implements HasComponentType {
  public final children:Array<Component>;

  public function new(props:{
    children:Children,
    ?key:Key
  }) {
    super(props.key);
    this.children = props.children;
  }

  function createElement() {
    return new Element(
      this, 
      element -> new FragmentEngine(element, (element) -> element.component.children)
    );
  }
}

class FragmentEngine implements ElementEngine {
  final element:ElementOf<Fragment>;
  final render:(element:ElementOf<Fragment>)->Array<Component>;

  var children:Array<Element> = [];
  var marker:Null<Element> = null;

  public function new(element, render) {
    this.element = element;
    this.render = render;
  }

  public function init() {
    var slot = element.slot;
    var previous:Null<Element> = slot != null ? slot.previous : null;
    
    marker = createMarker();
    marker.mount(element, createSlot(-1, previous));
    
    var previous = marker;
    var components = renderSafe();
    var newChildren:Array<Element> = [];
    for (i => component in components) {
      var child = component.createElement();
      child.mount(element, createSlot(i, previous));
      newChildren.push(child);
      previous = child;
    }

    this.children = newChildren;
  }

  public function hydrate(cursor:Cursor) {
    var slot = element.slot;
    var previous:Null<Element> = slot != null ? slot.previous : null;

    marker = createMarker();
    marker.mount(element, createSlot(-1, previous));
    
    var previous = marker;
    var components = renderSafe();
    var newChildren:Array<Element> = [];
    for (i => component in components) {
      var child = component.createElement();
      child.hydrate(cursor, element, createSlot(i, previous));
      newChildren.push(child);
      previous = child;
    }

    this.children = newChildren;
  }

  public function update() {
    var currentSlot = element.slot;
    if (currentSlot != null && marker != null) marker.updateSlot(currentSlot);
    children = diffChildren(element, children, renderSafe());
  }

  public function getAdaptor():Adaptor {
    return findParentAdaptor(element);
  }

  public function getObject():Dynamic {
    if (children.length == 0) {
      return getMarker().getObject();
    }
    return children[children.length - 1].getObject();
  }

  public function createSlot(localIndex:Int, previous:Null<Element>):Slot {
    var parentSlot = element.slot;
    var index = parentSlot == null ? 0 : parentSlot.index;
    return new FragmentSlot(index, localIndex + 1, previous);
  }

  public function updateSlot(slot:Null<Slot>) {
    element.slot = slot;
    if (marker != null && slot != null) {
      // @todo: not sure if this is needed OR if it will work.
      marker.updateSlot(createSlot(-1, slot.previous));
      var previous = marker;
      for (i => child in children) {
        child.updateSlot(createSlot(i, previous));
        previous = child;
      }
    }
  }

  public function visitChildren(visitor:(child:Element) -> Bool) {
    if (!visitor(getMarker())) return;
    for (child in children) if (!visitor(child)) break;
  }

  public function createChildrenQuery():ChildrenQuery {
    return new ChildrenQuery(element);
  }

  public function createAncestorQuery():AncestorQuery {
    return new AncestorQuery(element);
  }

  public function handleThrownObject(target:Element, e:Dynamic) {
    bubbleThrownObjectUp(element, target, e);
  }

  public function dispose() {
    if (marker != null) {
      marker.dispose();
      marker = null;
    }

    for (child in children) child.dispose();
    children = [];
  }

  function getMarker():Element {
    Debug.assert(marker != null);
    return marker;
  }

  function createMarker() {
    return element
      .getAdaptor()
      .createPlaceholder()
      .createElement();
  }

  function renderSafe() {
    return render(element).filter(e -> e != null);
  }
}

class FragmentSlot extends Slot {
  public final localIndex:Int;

  public function new(index, localIndex, previous) {
    super(index, previous);
    this.localIndex = localIndex;
  }

  override function indexChanged(other:Slot):Bool {
    if (other.index != index)
      return true;
    if (other is FragmentSlot) {
      var otherFragment:FragmentSlot = cast other;
      return localIndex != otherFragment.localIndex;
    }
    return false;
  }
}
