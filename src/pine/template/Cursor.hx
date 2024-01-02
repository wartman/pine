package pine.template;

interface Cursor {
  public function current():Null<Dynamic>;
  public function currentChildren():Cursor;
  public function next():Void;
}
