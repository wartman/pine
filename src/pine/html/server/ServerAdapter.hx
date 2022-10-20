package pine.html.server;

class ServerAdapter extends Adapter {
  final process = new ServerProcess();
  final elementApplicator = new HtmlElementApplicator();
  final textApplicator = new HtmlTextApplicator();

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
