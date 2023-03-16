package pine;

import pine.state.Signal;
import pine.element.ProxyElementEngine.useProxyElementEngine;
import pine.diffing.Key;
import pine.core.HasComponentType;

using Kit;

enum SuspenseStatus<T> {
  Suspended;
  Active(result:Result<T>);
}

// @todo: Maybe it would be easiest to just us a Proxy?
class Suspense<T> extends Component implements HasComponentType {
  final data:Task<T>;
  final render:(status:SuspenseStatus<T>)->Child;

  public function new(props:{
    ?key:Key,
    data:Task<T>,
    render:(status:SuspenseStatus<T>)->Child
  }) {
    super(props.key);
    this.data = props.data;
    this.render = props.render;
  }  

  public function createElement():Element {
    var link:Maybe<Cancellable> = None;
    var element:ElementOf<Suspense<T>> = new Element(this, useProxyElementEngine((element:ElementOf<Suspense<T>>) -> {
      
      // This won't work. We need to use a Signal somewhere...
      link.ifExtract(Some(link), link.cancel());
      link = Some(element.component.data.handle(result -> switch result {
        case Success(value):
        case Failure(exception):
      }));
      null;
    }));

    // hmm

    return element;
  }
}

class Suspended {

}

