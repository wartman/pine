package pine.html.dom;

class DomBootstrap extends HtmlBootstrap<js.html.Element> {
  public function getDefaultRoot() {
    return js.Browser.document.getElementById('root');
  }

  function createHydrator():HydrationCursor {
    return new DomHydrationCursor(el);
  }

  function createRoot(child:Component):RootComponent {
    return new DomRoot({el: el, child: child});
  }
}
