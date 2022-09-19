package pine.internal;

class MultiChildrenManager implements ChildrenManager {
  final render:()->Array<Null<Component>>;
  final factory:ElementFactory;
  var children:Array<Element> = [];

  public function new(render, factory) {
    this.render = render;
    this.factory = factory;
  }

  function initPrevious(?slot:Slot):Null<Element> {
    return null;
  }

  public function hydrate(cursor:HydrationCursor, ?slot:Slot) {
    var components = renderSafe();
    var objects = cursor.currentChildren();
    var children:Array<Element> = [];
    var previous:Null<Element> = initPrevious(slot);

    for (i in 0...components.length) {
      var comp = components[i];
      var element = factory.hydrateChild(objects, comp, factory.createSlot(i, previous));
      children.push(element);
      previous = element;
    }

    Debug.assert(objects.current() == null);

    this.children = children;
  }

  public function update(?previousComponent:Component, ?slot:Slot) {
    if (previousComponent == null) {
      initializeChildren(slot);
    } else {
      rebuildChildren(slot);
    }
  }

  public function updateSlot(?slot:Slot) {
    // Noop?
    // for (child in children) child.updateSlot(slot);
  }

  function initializeChildren(?slot:Slot) {
    var components = renderSafe();
    var previous:Null<Element> = initPrevious(slot);
    var children:Array<Element> = [];

    for (i in 0...components.length) {
      var comp = components[i];
      var element = factory.createChild(comp, factory.createSlot(i, previous));
      children.push(element);
      previous = element;
    }

    this.children = children;
  }

  function rebuildChildren(?slot:Slot) {
    var components:Array<Component> = renderSafe();
    children = diffChildren(children, components);
  }

  public function visit(visitor:ElementVisitor) {
    for (child in children) visitor.visit(child);
  }

  public function dispose() {
    for (child in children) child.dispose();
    children = [];
  }

  inline function renderSafe():Array<Component> {
    return cast render().filter(c -> c != null);
  }
  
  function diffChildren(oldChildren:Array<Element>, newComponents:Array<Component>):Array<Element> {
    // Almost entirely taken from: https://github.com/flutter/flutter/blob/6af40a7004f886c8b8b87475a40107611bc5bb0a/packages/flutter/lib/src/components/framework.dart#L5761
    var newHead = 0;
    var oldHead = 0;
    var newTail = newComponents.length - 1;
    var oldTail = oldChildren.length - 1;
    var previousChild:Null<Element> = null;
    var newChildren:Array<Null<Element>> = [];

    // Scan from the top of the list, syncing until we can't anymore.
    while ((oldHead <= oldTail) && (newHead <= newTail)) {
      var oldChild = oldChildren[oldHead];
      var newComponent = newComponents[newHead];
      if (oldChild == null || !oldChild.component.shouldBeUpdated(newComponent)) {
        break;
      }

      var newChild = factory.updateChild(oldChild, newComponent, factory.createSlot(newHead, previousChild));
      newChildren[newHead] = newChild;
      previousChild = newChild;
      newHead += 1;
      oldHead += 1;
    }

    // Scan from the bottom, without syncing.
    while ((oldHead <= oldTail) && (newHead <= newTail)) {
      var oldChild = oldChildren[oldTail];
      var newComponent = newComponents[newTail];
      if (oldChild == null || !oldChild.component.shouldBeUpdated(newComponent)) {
        break;
      }
      oldTail -= 1;
      newTail -= 1;
    }

    // Scan the middle.
    var hasOldChildren = oldHead <= oldTail;
    var oldKeyedChildren:Null<Key.KeyMap<Element>> = null;

    // If we still have old children, go through the array and check
    // if any have keys. If they don't, remove them.
    if (hasOldChildren) {
      oldKeyedChildren = Key.createMap();
      while (oldHead <= oldTail) {
        var oldChild = oldChildren[oldHead];
        if (oldChild != null) {
          if (oldChild.component.key != null) {
            oldKeyedChildren.set(oldChild.component.key, oldChild);
          } else {
            factory.destroyChild(oldChild);
          }
        }
        oldHead += 1;
      }
    }

    // Sync/update any new elements. If we have more children than before
    // this is where things will happen.
    while (newHead <= newTail) {
      var oldChild:Null<Element> = null;
      var newComponent = newComponents[newHead];

      // Check if we already have an element with a matching key.
      if (hasOldChildren) {
        var key = newComponent.key;
        if (key != null) {
          if (oldKeyedChildren == null) {
            throw 'assert'; // This should never happen
          }

          oldChild = oldKeyedChildren.get(key);
          if (oldChild != null) {
            if (oldChild.component.shouldBeUpdated(newComponent)) {
              // We do -- remove a keyed child from the list so we don't
              // unsync it later.
              oldKeyedChildren.remove(key);
            } else {
              // We don't -- ignore it for now.
              oldChild = null;
            }
          }
        }
      }

      var newChild = factory.updateChild(oldChild, newComponent, factory.createSlot(newHead, previousChild));
      newChildren[newHead] = newChild;
      previousChild = newChild;
      newHead += 1;
    }

    newTail = newComponents.length - 1;
    oldTail = oldChildren.length - 1;

    // Update the bottom of the list.
    while ((oldHead <= oldTail) && (newHead <= newTail)) {
      var oldChild = oldChildren[oldHead];
      var newComponent = newComponents[newHead];
      var newChild = factory.updateChild(oldChild, newComponent, factory.createSlot(newHead, previousChild));
      newChildren[newHead] = newChild;
      previousChild = newChild;
      newHead += 1;
      oldHead += 1;
    }

    // Clean up any remaining children. At this point, we should only
    // have to worry about keyed elements that are lingering around.
    if (hasOldChildren && (oldKeyedChildren != null && oldKeyedChildren.isNotEmpty())) {
      oldKeyedChildren.each((_, element) -> factory.destroyChild(element));
    }

    Debug.assert(!Lambda.exists(newChildren, el -> el == null));

    return cast newChildren;
  }
}
