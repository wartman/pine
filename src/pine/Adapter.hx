package pine;

abstract class Adapter {
  public static function from(context:Context):Adapter {
    return context.getRoot().getAdapter();
  }

  abstract public function getProcess():Process;
  abstract public function getApplicator(component:ObjectComponent):ObjectApplicator<Dynamic>;
  abstract public function createPlaceholder():Component;
  abstract public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent;
}
