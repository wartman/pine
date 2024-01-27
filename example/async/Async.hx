package async;

import ex.Button;
import haxe.Timer;
import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.*;
import pine.signal.*;

using Kit;
using pine.signal.Tools;

function asyncRoot() {
  var root = Browser.document.body.querySelector('#async-root');
  ClientRoot.mount(root, () -> Html.template(<Suspense
    onSuspended={() -> trace('Suspended')}
    onComplete={() -> trace('Done')}  
  >
    <Async />
  </Suspense>));
}

class Async extends Component {
  function render() {
    var id = new Signal(0);
    var resource = Resource.suspends(this).fetch(() -> {
      var id = id();
      new Task(activate -> Timer.delay(() -> activate(Ok(id)), 1000));
    });

    return Html.template(<div>
      <div>
        // You could wrap the Resource in a `<Scope>...</Scope>`,
        // but `pine.signal.Tools` gives us the handy `scope` extension
        // method that lets us use the resource directly.
        {resource.scope(res -> switch res {
          case Error(e): <p>{e.message}</p>;
          case Ok(value): <p>{value}</p>;
          case Loading: <p>"Loading..."</p>;
        })}
      </div>
      <Button 
        action={() -> id.update(id -> id + 1)}
        disabled={new Computation(() -> switch resource() {
          case Loading | Error(_): true;
          default: false;
        })}
      >"Reload"</Button>
    </div>);
  }
}
