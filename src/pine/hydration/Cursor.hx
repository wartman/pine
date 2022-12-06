package pine.hydration;

interface Cursor {
  public function current():Null<Dynamic>;
  public function currentChildren():Cursor;
  public function next():Void;
  public function move(current:Dynamic):Void;
  public function clone():Cursor; 
}
