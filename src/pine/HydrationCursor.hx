package pine;

interface HydrationCursor {
  public function current():Null<Dynamic>;
  public function currentChildren():HydrationCursor;
  public function next():Void;
  public function move(current:Dynamic):Void;
}
