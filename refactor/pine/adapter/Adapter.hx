package pine.adapter;

import haxe.ds.Option;

using pine.core.OptionTools;

abstract class Adapter {
  public static function from(context:Context):Adapter {
    return maybeFrom(context).orThrow('No Adapater was found');
  }

  public static function maybeFrom(context:Context):Option<Adapter> {
    return switch context.getRoot() {
      case Some(root): Some(root.getAdapter());
      case None: None;
    }
  }

  abstract public function getProcess():Process;
  // abstract public function getApplicator(component:ObjectComponent):ObjectApplicator<Dynamic>;
  // abstract public function getTextApplicator(component:ObjectComponent):ObjectApplicator<Dynamic>;
  abstract public function createPlaceholder():Component;
  // abstract public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent;
}
