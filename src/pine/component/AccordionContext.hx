package pine.component;

import pine.signal.*;

enum abstract AccordionContextStatus(Int) {
  final Updating;
  final Pending;
}

@:fallback(new AccordionContext({ sticky: false }))
class AccordionContext implements Context {
  final children:Map<CollapseContext, Observer> = [];
  var sticky:Bool;
  var status:AccordionContextStatus = Pending;

  public function new(props:{
    sticky:Bool
  }) {
    this.sticky = props.sticky;
  }

  public function setSticky(sticky:Bool) {
    this.sticky = sticky;
  }

  public function add(collapse:CollapseContext) {
    var prev = status;
    status = Updating;
    children.set(collapse, new Observer(() -> switch collapse.status() {
      case Expanded if (status != Updating && !sticky):
        status = Updating;
        for (item => _ in children) {
          if (item != collapse) item.collapse();
        }
        status = Pending;  
      default:
    }));
    status = prev;
  }

  public function remove(collapse:CollapseContext) {
    var obs = children.get(collapse);
    if (obs != null) {
      obs.dispose();
      children.remove(collapse);
    }
  }
  
  public function collapse() {
    for (item => _ in children) {
      item.collapse();
    }
  }

  public function dispose() {
    var items = children.keys();
    for (item in items) remove(item);
  }
}
