package pine.adaptor;

import haxe.ds.Option;
import pine.element.Slot;

using pine.core.OptionTools;

abstract class Adaptor {
  public static function from(context:Context):Adaptor {
    return context.getAdaptor();
  }

  public static function maybeFrom(context:Context):Option<Adaptor> {
    return Some(context.getAdaptor());
  }

  var isScheduled:Bool = false;
  var invalidElements:Null<Array<Element>> = null;

  abstract public function getProcess():Process;
  abstract public function createPlaceholder():ObjectComponent;
  abstract public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent;
  abstract public function createObject(type:ObjectType, component:ObjectComponent):Dynamic;
  abstract public function updateObject(type:ObjectType, object:Dynamic, component:ObjectComponent, previousComponent:Null<ObjectComponent>):Void;
  abstract public function insertObject(type:ObjectType, object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic):Void;
  abstract public function moveObject(type:ObjectType, object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic):Void;
  abstract public function removeObject(type:ObjectType, object:Dynamic, slot:Null<Slot>):Void;

  public function requestRebuild(element:Element):Void {
    if (invalidElements == null) {
      invalidElements = [];
      scheduleRebuildInvalidElements();
    }

    if (invalidElements.contains(element)) {
      return;
    }

    invalidElements.push(element);
  }
  
  function scheduleRebuildInvalidElements() {
    if (isScheduled) return;
    isScheduled = true;
    getProcess().defer(rebuildInvalidElements);
  }

  function rebuildInvalidElements() {
    var elements = invalidElements.copy();
    invalidElements = null;
    
    isScheduled = false;

    if (elements == null) {
      return;
    }

    for (el in elements) el.rebuild();
  }
}
