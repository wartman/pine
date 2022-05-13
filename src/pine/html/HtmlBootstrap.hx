package pine.html;

abstract class HtmlBootstrap<Object> {
  final el:Object;

  public function new(?el:Object) {
    this.el = el == null ? getDefaultRoot() : el;
  }

  public function mount(child:Component) {
    var root = createRoot(child);
    var el:RootElement = cast root.createElement();
    el.bootstrap();
    return el;
  }

  public function hydrate(child:Component) {
    var root = createRoot(child);
    var el:RootElement = cast root.createElement();
    el.hydrate(createHydrator(), null);
    return el;
  }

  abstract function getDefaultRoot():Object;

  abstract function createHydrator():HydrationCursor;

  abstract function createRoot(child:Component):RootComponent;
}
