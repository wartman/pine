package pine.adaptor;

import haxe.ds.Option;

using pine.core.OptionTools;

abstract class Adaptor {
  public static function from(context:Context):Adaptor {
    return maybeFrom(context).orThrow('No Adaptor was found');
  }

  public static function maybeFrom(context:Context):Option<Adaptor> {
    return context.getAdaptor();
  }

  var isScheduled:Bool = false;
  var invalidElements:Null<Array<Element>> = null;

  abstract public function getProcess():Process;
  abstract public function getObjectApplicator(type:ObjectType):ObjectApplicator<Dynamic>;
  abstract public function createPlaceholder():Component;
  abstract public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent;

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
