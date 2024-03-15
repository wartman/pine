package pine.component;

@:fallback(FocusContext.instance())
class FocusContext implements Context {
  static public function instance() {
    static var context:Null<FocusContext> = null;
    if (context == null) context = new FocusContext();
    return context;
  }

  #if (js && !nodejs)
  var previous:Null<js.html.Element> = null;
  #end

  public function new() {}

  public function focus(object:Dynamic) {
    #if (js && !nodejs)
    var el = object.as(js.html.Element);
    if (previous == null) {
      previous = el?.ownerDocument?.activeElement;
    }
    el?.focus();
    #end
  }

  public function returnFocus() {
    #if (js && !nodejs)
    previous?.focus();
    previous = null;
    #end
  }

  public function dispose() {}
}
