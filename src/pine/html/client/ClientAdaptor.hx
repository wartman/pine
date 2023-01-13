package pine.html.client;

import pine.adaptor.*;
import pine.object.NullObjectApplicator;

class ClientAdaptor extends Adaptor {
  final process = new ClientProcess();
  final elementApplicator = new HtmlElementApplicator();
  final textApplicator = new HtmlTextApplicator();
  final rootApplicator = new NullObjectApplicator();

  public function new() {}

  public function getProcess():Process {
    return process;
  }

  public function getObjectApplicator(type:ObjectType):ObjectApplicator<Dynamic> {
    return switch type {
      case ObjectRoot: rootApplicator;
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
