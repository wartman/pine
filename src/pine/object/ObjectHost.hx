package pine.object;

interface ObjectHost {
  private function initializeObject():Void;
  private function teardownObject():Void;
}