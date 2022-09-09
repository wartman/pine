package pine.html.server;

class ServerAdapter extends Adapter {
  static final applicators = new ObjectApplicatorCollection([
    HtmlElementComponent.applicatorType => new HtmlElementApplicator(),
    HtmlTextComponent.applicatorType => new HtmlTextApplicator()
  ]);

  static final process = new ServerProcess();

  public function new() {}  

  public function getProcess():Process {
    return process;
  }

  public function getApplicator(component:ObjectComponent):ObjectApplicator<Dynamic> {
    var applicator = applicators.get(component.getApplicatorType());
    Debug.alwaysAssert(applicator != null, 'No applicator found');
    return applicator;
  }

  public function createPlaceholder():Component {
    return new HtmlTextComponent({ content: '' });
  }

  public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent {
    return new ServerRoot({ el: target, child: child });
  }
}