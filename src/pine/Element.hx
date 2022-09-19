package pine;

import haxe.ds.Option;

enum ElementStatus {
  Pending;
  Valid;
  Invalid;
  Building;
  Disposed;
}

enum abstract HydratingStatus(Bool) to Bool {
  var IsHydrating = true;
  var NotHydrating = false;
}

abstract class Element 
  implements Context 
  implements InitContext
  implements Disposable 
  implements DisposableHost 
{
  final disposables:Array<Disposable> = [];
  var component:Component;
  var slot:Null<Slot> = null;
  var status:ElementStatus = Pending;
  var hydratingStatus:HydratingStatus = NotHydrating;
  var parent:Null<Element> = null;
  var root:Null<Root> = null;

  public function new(component) {
    this.component = component;
  }

  public function getRoot():Root {
    Debug.alwaysAssert(root != null);
    return root;
  }

  public function mount(parent:Null<Element>, ?slot:Slot) {
    performSetup(parent, slot);
    status = Building;
    performBuild(null);
    status = Valid;
  }

  public function hydrate(cursor:HydrationCursor, parent:Null<Element>, ?slot:Slot) {
    hydratingStatus = IsHydrating;
    performSetup(parent, slot);
    status = Building;
    performHydrate(cursor);
    status = Valid;
    hydratingStatus = NotHydrating;
  }

  public function update(component:Component) {
    Debug.assert(status != Building);

    status = Building;
    var previousComponent = this.component;
    this.component = component;
    performBuild(previousComponent);
    status = Valid;
  }

  public function rebuild() {
    Debug.assert(status != Building);

    if (status != Invalid) {
      return;
    }

    status = Building;
    performBuild(component);
    status = Valid;
  }

  public function dispose() {
    Debug.assert(status != Building && status != Disposed);

    visitChildren(child -> child.dispose());

    for (disposable in disposables) disposable.dispose();

    status = Disposed;
    parent = null;
    root = null;
    slot = null;
  }

  function performSetup(parent:Null<Element>, ?slot:Slot) {
    Debug.assert(status == Pending, 'Attempted to mount an already mounted Element');

    this.parent = parent;
    this.slot = slot;
    
    if (parent != null) this.root = parent.getRoot();

    status = Valid;
  }

  public function invalidate() {
    Debug.assert(status != Pending, 'Attempted to invalidate an Element before it was mounted');
    Debug.assert(status != Disposed, 'Attempted to invalidate an Element after it was disposed');
    Debug.assert(status != Building, 'Attempted to invalidate an Element while it was building');

    if (status == Invalid) {
      return;
    }

    status = Invalid;

    if (root != null) {
      root.requestRebuild(this);
    }
  }

  abstract function performHydrate(cursor:HydrationCursor):Void;

  abstract function performBuild(previousComponent:Null<Component>):Void;

  abstract public function visitChildren(visitor:ElementVisitor):Void;

  public function addDisposable(disposable:Disposable) {
    disposables.push(disposable);
  }

  public final inline function getComponent<T:Component>():Null<T> {
    return cast component;
  }

  public function isHydrating():Bool {
    return hydratingStatus;
  }

  public function getParent():Null<Element> {
    return parent;
  }

  public function queryAncestors(query:(parent:Element) -> Bool):Option<Element> {
    if (parent == null) {
      return None;
    }
    if (query(parent)) {
      return Some(parent);
    }
    return parent.queryAncestors(query);
  }

  public function findAncestorOfType<T:Element>(kind:Class<T>):Option<T> {
    if (parent == null) {
      if (Std.isOfType(this, kind)) return Some(cast this);
      return None;
    }

    return switch (Std.downcast(parent, kind) : Null<T>) {
      case null: parent.findAncestorOfType(kind);
      case found: Some(cast found);
    }
  }

  function findAncestorObject():Dynamic {
    return switch findAncestorOfType(ObjectElement) {
      case None: Debug.error('Unable to find ObjectElement ancestor.');
      case Some(root): root.getObject();
    }
  }

  // @todo: This is a potentially costly method. Is there a way we can make it
  // work better? Or should we simply discourage it?
  public function queryChildren(query:(child:Element) -> Bool):Option<Array<Element>> {
    var found:Array<Element> = [];
    visitChildren(child -> {
      if (query(child)) found.push(child);
      switch child.queryChildren(query) {
        case Some(children): for (c in children) found.push(c);
        case None:
      }
    });
    return if (found.length == 0) None else Some(found);
  }

  public function queryFirstChild(query:(child:Element) -> Bool):Option<Element> {
    var found:Null<Element> = null;
    visitChildren(child -> {
      if (found != null) return;
      if (query(child))
        found = child;
      else 
        switch child.queryFirstChild(query) {
          case Some(child) if (found == null):
            found = child;
          default:
        }
    });
    return if (found == null) None else Some(found);
  }

  public function findChildrenOfType<T:Element>(kind:Class<T>):Option<Array<T>> {
    var found:Array<T> = [];
    visitChildren(child -> if (Std.isOfType(child, kind)) {
      found.push(cast child);
    });
    return if (found.length == 0) None else Some(found);
  }

  public function getObject():Dynamic {
    var object:Null<Dynamic> = null;

    function visit(element:Element) {
      Debug.assert(object == null, 'Element has more than one objects');
      if (element.status == Disposed) {
        return;
      }
      if (element is ObjectElement) {
        object = element.getObject();
      } else {
        element.visitChildren(visit);
      }
    }
    visit(this);

    Debug.alwaysAssert(object != null, 'Element does not have an object');

    return object;
  }

  function updateChild(?child:Element, ?component:Component, ?slot:Slot):Null<Element> {
    if (component == null) {
      if (child != null) removeChild(child);
      return null;
    }

    return if (child != null) {
      if (child.component == component) {
        if (child.slot != slot) updateSlotForChild(child, slot);
        child;
      } else if (child.component.shouldBeUpdated(component)) {
        if (child.slot != slot) updateSlotForChild(child, slot);
        child.update(component);
        child;
      } else {
        removeChild(child);
        createElementForComponent(component, slot);
      }
    } else {
      createElementForComponent(component, slot);
    }
  }

  function updateSlot(slot:Null<Slot>) {
    this.slot = slot;
    visitChildren(child -> child.updateSlot(slot));
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

      var newChild = updateChild(oldChild, newComponent, createSlotForChild(newHead, previousChild));
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
            removeChild(oldChild);
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

      var newChild = updateChild(oldChild, newComponent, createSlotForChild(newHead, previousChild));
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
      var newChild = updateChild(oldChild, newComponent, createSlotForChild(newHead, previousChild));
      newChildren[newHead] = newChild;
      previousChild = newChild;
      newHead += 1;
      oldHead += 1;
    }

    // Clean up any remaining children. At this point, we should only
    // have to worry about keyed elements that are lingering around.
    if (hasOldChildren && (oldKeyedChildren != null && oldKeyedChildren.isNotEmpty())) {
      oldKeyedChildren.each((_, element) -> removeChild(element));
    }

    Debug.assert(!Lambda.exists(newChildren, el -> el == null));

    return cast newChildren;
  }

  function updateSlotForChild(child:Element, slot:Null<Slot>) {
    child.updateSlot(slot);
  }

  function removeChild(child:Element) {
    child.dispose();
  }

  function createElementForComponent(component:Component, ?slot:Slot) {
    var element = component.createElement();
    element.mount(this, slot);
    return element;
  }

  function hydrateElementForComponent(cursor:HydrationCursor, component:Component, ?slot:Slot) {
    var element = component.createElement();
    element.hydrate(cursor, this, slot);
    return element;
  }

  function createSlotForChild(index:Int, previous:Null<Element>) {
    return new Slot(index, previous);
  }
}
