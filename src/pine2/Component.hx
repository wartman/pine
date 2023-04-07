package pine2;

import pine2.internal.ObjectHost;
import kit.Assert;
import pine2.Disposable;
import pine2.signal.*;
import pine2.internal.Adaptor;

using Kit;

enum ComponentStatus {
  Pending;
  Valid;
  Invalid;
  Building;
  Disposing;
  Disposed;
}

abstract class Component implements Disposable implements DisposableHost {
  final disposables:DisposableCollection = new DisposableCollection();

  var parent:Null<Component> = null;
  var slot:Null<Slot> = null;
  var adaptor:Null<Adaptor> = null;
  var status:ComponentStatus = Pending;

  public function mount(?parent:Component, ?slot:Slot) {
    assert(status == Pending);

    this.slot = slot;
    this.parent = parent;
    if (this.adaptor == null) this.adaptor = parent?.getAdaptor();

    initialize();
    status = Valid;
  }

  public function createSlot(index:Int, previous:Null<Component>):Slot {
    return new Slot(index, previous);
  }

  public function getSlot():Slot {
    return slot;
  }

  public function updateSlot(?newSlot:Slot) {
    this.slot = newSlot;
  }

  public function getAdaptor():Adaptor {
    assert(adaptor != null);
    return adaptor;
  }

  public function findAncestor(match:(parent:Component)->Bool):Maybe<Component> {
    return switch parent {
      case null: None;
      case parent if (match(parent)): Some(parent);
      case parent: parent.findAncestor(match);
    }
  }

  public function findAncestorOfType<T:Component>(type:Class<T>):Maybe<T> {
    return cast findAncestor(parent -> Std.isOfType(parent, type));
  }

  public function findNearestObjectHostAncestor():Dynamic {
    return findAncestor(ancestor -> Std.isOfType(ancestor, ObjectHost))
      .map(o -> o.getObject())
      .orThrow('No parent object found');
  }

  inline function signal<T>(value:T):Signal<T> {
    return new Signal(value);
  }

  inline function compute<T>(compute):Computation<T> {
    var computed = new Computation(compute);
    addDisposable(computed);
    return computed;
  }

  inline function effect(handler:()->Void) {
    var observer = new Observer(handler);
    addDisposable(observer);
    return observer;
  }

  public function queryChildren(match:(child:Component)->Bool, recursive:Bool = false):Array<Component> {
    var results:Array<Component> = [];
    visitChildren(child -> {
      if (match(child)) results.push(child);
      if (recursive) {
        results = results.concat(child.queryChildren(match));
      }
      true;
    });
    return results;
  }

  public function findChild(match:(child:Component)->Bool, recursive:Bool = false):Maybe<Component> {
    var result:Null<Component> = null;
    visitChildren(child -> {
      if (match(child)) {
        result = child;
        return false;
      }
      return true;
    });
    return switch result {
      case null if (recursive):
        visitChildren(child -> switch child.findChild(match, true) {
          case Some(value):
            result = value;
            false;
          case None:
            true;
        });
        if (result == null) None else Some(result);
      case null: 
        None;
      default: 
        Some(result);
    }
  }

  public function queryChildrenOfType<T:Component>(type:Class<T>, recursive = false):Array<T> {
    return cast queryChildren(child -> Std.isOfType(child, type), recursive);
  }

  public function findChildOfType<T:Component>(type:Class<T>, recursive = false):T {
    return cast findChild(child -> Std.isOfType(child, type), recursive);
  }

  abstract public function getObject():Dynamic;
  
  abstract public function visitChildren(visitor:(child:Component)->Bool):Void;
  
  abstract public function initialize():Void;

  public function addDisposable(disposable:DisposableItem) {
    disposables.addDisposable(disposable);
  }

  public function dispose() {
    if (status == Disposed) return;

    status = Disposing;
    visitChildren(child -> {
      child.dispose(); 
      true;
    });
    disposables.dispose();
    status = Disposed;
  }
}
