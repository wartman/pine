package pine;

interface InitContext extends Context extends DisposableHost {
  public function invalidate():Void;
}
