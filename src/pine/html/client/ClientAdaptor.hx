package pine.html.client;

import pine.adaptor.*;

class ClientAdaptor extends Adaptor {
  final process = new ClientProcess();
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
    return new ClientRoot({ el: target, child: child });
  }
}
