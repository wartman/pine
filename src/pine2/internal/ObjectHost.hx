package pine2.internal;

interface ObjectHost {
  private function initializeObject():Void;
  private function teardownObject():Void;
}
