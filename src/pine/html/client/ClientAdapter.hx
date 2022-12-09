package pine.html.client;

import pine.adapter.*;

class ClientAdapter extends Adapter {
  final process = new ClientProcess();
  final elementApplicator = new HtmlElementApplicator();
  final textApplicator = new HtmlTextApplicator();

  public function new() {}

  public function getProcess():Process {
    return process;
  }

  public function getApplicator():ObjectApplicator<Dynamic> {
    return elementApplicator;
  }

  public function getTextApplicator():ObjectApplicator<Dynamic> {
    return textApplicator;
  }

  public function createPlaceholder():Component {
    return new HtmlTextComponent({ content: '' });
  }

  public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent {
    return new ClientRoot({ el: target, child: child });
  }
}
