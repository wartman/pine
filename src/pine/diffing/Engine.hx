package pine.diffing;

import pine.debug.Debug;
import pine.element.*;

/**
  Determine if an Element should be created, removed, replaced or
  updated against the given Component.
**/
function updateChild(
  parent:Element,
  child:Null<Element>,
  component:Null<Component>,
  slot:Null<Slot>
):Null<Element> {
  if (component == null) {
    if (child != null) child.dispose();
    return null;
  }

  return if (child != null) {
    if (child.component == component) {
      if (!child.slots.equals(slot)) child.slots.update(slot);
      child;
    } else if (child.component.shouldBeUpdated(component)) {
      if (!child.slots.equals(slot)) child.slots.update(slot);
      child.update(component);
      child;
    } else {
      child.dispose();
      createElementForComponent(parent, component, slot);
    }
  } else {
    createElementForComponent(parent, component, slot);
  }
}

/**
  Diff a tree of Elements against the given list of Components.
  
  Almost entirely taken from: https://github.com/flutter/flutter/blob/6af40a7004f886c8b8b87475a40107611bc5bb0a/packages/flutter/lib/src/components/framework.dart#L5761
**/
function diffChildren(
  parent:Element,
  oldChildren:Array<Element>,
  newComponents:Array<Component>
):Array<Element> {
  var newHead = 0;
  var oldHead = 0;
  var slots = parent.slots;
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

    var newChild = updateChild(parent, oldChild, newComponent, slots.create(newHead, previousChild));
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
  var oldKeyedChildren:Null<KeyMap<Element>> = null;

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
          oldChild.dispose();
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

    var newChild = updateChild(parent, oldChild, newComponent, slots.create(newHead, previousChild));
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
    var newChild = updateChild(parent, oldChild, newComponent, slots.create(newHead, previousChild));
    newChildren[newHead] = newChild;
    previousChild = newChild;
    newHead += 1;
    oldHead += 1;
  }

  // Clean up any remaining children. At this point, we should only
  // have to worry about keyed elements that are lingering around.
  if (hasOldChildren && (oldKeyedChildren != null && oldKeyedChildren.isNotEmpty())) {
    oldKeyedChildren.each((_, element) -> element.dispose());
  }

  Debug.assert(!Lambda.exists(newChildren, el -> el == null));

  return cast newChildren;
}

private function createElementForComponent(parent:Element, component:Component, ?slot:Slot) {
  var element = component.createElement();
  element.mount(parent, slot);
  return element;
}
