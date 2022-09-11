package pine.html.dom;

class DomAdapter extends Adapter {
  static final process = new DomProcess();
  static final elementApplicator = new HtmlElementApplicator();
  static final textApplicator = new HtmlTextApplicator();

  public function new() {}

  public function getProcess() {
    return process;
  }

  public function getApplicator(component:ObjectComponent):ObjectApplicator<Dynamic> {
    return elementApplicator;
  }

  public function getTextApplicator(component:ObjectComponent):ObjectApplicator<Dynamic> {
    return textApplicator;
  }

  public function createPlaceholder():Component {
    return new HtmlTextComponent({ content: '' });
  }

  public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent {
    return new DomRoot({ el: target, child: child });
  }
}
