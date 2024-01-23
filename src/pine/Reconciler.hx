package pine;

import pine.debug.Debug;

class Reconciler implements Disposable {
  final parent:View;
  final adaptor:Adaptor;
  final createSlot:(index:Int, previous:Null<Dynamic>)->Slot;

  var currentChildren:Array<View> = [];

  public function new(parent, adaptor, createSlot) {
    this.parent = parent;
    this.adaptor = adaptor;
    this.createSlot = createSlot;
  }

  public inline function last() {
    return currentChildren[currentChildren.length - 1];
  }

  public inline function each(handler:(index:Int, view:View)->Void) {
    for (index => view in currentChildren) handler(index, view);
  }

  public function reconcile(newChildren:Array<View>):Void {
    var newHead = 0;
    var oldHead = 0;
    var newTail = newChildren.length - 1;
    var oldTail = currentChildren.length - 1;
    var previousChild:Null<View> = null;
  
    // Scan from the top, avoiding changing anything if we don't need to.
    while ((oldHead <= oldTail) && (newHead <= newTail)) {
      var oldChild = currentChildren[oldHead];
      var newChild = newChildren[newHead];
  
      if (oldChild == null || oldChild != newChild) break;
  
      previousChild = newChild;
      newHead += 1;
      oldHead += 1;
    }
  
    // Scan from the bottom, checking if we have any remaining
    // Components in the old array.
    while ((oldHead <= oldTail) && (newHead <= newTail)) {
      var oldChild = currentChildren[oldTail];
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
        var oldChild = currentChildren[oldHead];
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
  
      if (!currentChildren.contains(newChild)) {
        newChild.mount(parent, adaptor, createSlot(newHead, previousChild?.getPrimitive()));
      } else {
        assert(newChild.getParent() == parent);
        newChild.setSlot(createSlot(newHead, previousChild?.getPrimitive()));
      }
  
      previousChild = newChild;
      newHead += 1; 
    }
  
    currentChildren = newChildren;
  }

  public function dispose() {
    for (child in currentChildren) child.dispose();
    currentChildren = [];
  }
}
