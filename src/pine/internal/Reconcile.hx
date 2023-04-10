package pine.internal;

function reconcileChildren(parent:Component, oldChildren:Array<Component>, newChildren:Array<Component>):Array<Component> {
  var newHead = 0;
  var oldHead = 0;
  var newTail = newChildren.length - 1;
  var oldTail = oldChildren.length - 1;
  var previousChild:Null<Component> = null;

  // Scan from the top, avoiding changing anything if we don't need to.
  while ((oldHead <= oldTail) && (newHead <= newTail)) {
    var oldChild = oldChildren[oldHead];
    var newChild = newChildren[newHead];

    if (oldChild == null || oldChild != newChild) break;

    previousChild = newChild;
    newHead += 1;
    oldHead += 1;
  }

  // Scan from the bottom, checking if we have any remaining
  // Components in the old array.
  while ((oldHead <= oldTail) && (newHead <= newTail)) {
    var oldChild = oldChildren[oldTail];
    var newChild = newChildren[newTail];
    
    if (oldChild == null || oldChild != newChild) break;

    oldTail -= 1;
    newTail -= 1;
  }

  final hasOldChildren = oldHead <= oldTail;

  // If we do have old children, check if there are Components
  // that no longer exist in the new array.
  if (hasOldChildren) {
    while (oldHead <= oldTail) {
      var oldChild = oldChildren[oldHead];
      if (oldChild != null) {
        if (!newChildren.contains(oldChild)) oldChild.dispose();
      }
      oldHead += 1;
    }
  }

  // Check the new children array, mounting components that
  // aren't present yet or just moving components that already
  // exist.
  while (newHead <= newTail) {
    var newChild = newChildren[newHead];

    if (newChild == null) continue;

    if (!oldChildren.contains(newChild)) {
      newChild.mount(parent, parent.createSlot(newHead, previousChild));
    } else {
      newChild.updateSlot(parent.createSlot(newHead, previousChild));
    }

    previousChild = newChild;
    newHead += 1; 
  }

  return newChildren;
}
