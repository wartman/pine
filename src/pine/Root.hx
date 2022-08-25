package pine;

interface Root {
  public function getApplicator<T:ObjectComponent>(component:T):ObjectApplicator<T>;
  public function requestRebuild(element:Element):Void;
  public function createPlaceholder():Component;
  public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent;
}
