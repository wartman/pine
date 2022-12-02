package pine.element.auto;

typedef Trackable<T> = {
  public function initTrackedObject():T;
  public function getTrackedObject():T;
  public function reuseTrackedObject(trackedObject:T):T;
}
