package pine;

interface Scheduler {
  public function schedule(item:() -> Void):Void;
}
