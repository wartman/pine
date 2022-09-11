package pine.html.server;

class ServerAdapter extends Adapter {
  static final process = new ServerProcess();
  static final elementApplicator = new HtmlElementApplicator();
  static final textApplicator = new HtmlTextApplicator();

  public function new() {}  

  public function getProcess():Process {
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
    return new ServerRoot({ el: target, child: child });
  }
}