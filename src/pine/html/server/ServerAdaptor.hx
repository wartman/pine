package pine.html.server;

import pine.adaptor.*;

class ServerAdaptor extends Adaptor {
  final process = new ServerProcess();
  final elementApplicator = new HtmlElementApplicator();
  final textApplicator = new HtmlTextApplicator();

  public function new() {}  

  public function getProcess():Process {
    return process;
  }
  
  public function getObjectApplicator(type:ObjectType):ObjectApplicator<Dynamic> {
    return switch type {
      case ObjectText: textApplicator;
      default: elementApplicator;
    }
  }

  public function createPlaceholder():Component {
    return new HtmlTextComponent({ content: '' });
  }

  public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent {
    return new ServerRoot({ el: target, child: child });
  }
}
