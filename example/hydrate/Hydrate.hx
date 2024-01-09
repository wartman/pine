package hydrate;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.*;
import pine.html.server.*;
import pine.signal.Signal;
import ex.*;

function hydrateRoot() {
  // We would never actually do this in a real app -- create the component
  // as a string, insert it into the HTML, and *then* hydrate it --
  // but it should give you an idea of how it all works.

  var state = new CounterState({ count: 0 });
  // Pretend we've created this HTML on a server and sent it
  // to the client:
  var html = ServerRoot.render(_ -> Html.template(<div id="hydrate-root">
    <Counter state=state/>
  </div>));

  Browser.document.body.querySelector('#hydrate-display').innerText = html;
  Browser.document.body.querySelector('#hydrate-target').innerHTML = html;

  var root = Browser.document.getElementById('hydrate-root');
  ClientRoot.hydrate(root, _ -> Counter.build({ state: state }));
}

class CounterState extends Model {
  @:signal public final count:Int;
  @:computed public final display:String = Std.string(count());

  @:action
  public function decrement() {
    if (count() > 0) count.update(i -> i - 1);
  }

  @:action
  public function increment() {
    count.update(i -> i + 1);
  }
}

class Counter extends Component {
  @:attribute final state:CounterState;

  function render(context:Context) {
    return Html.template(<div dataset={[ 'fooBar' => 'bar' ]}>
      'This is some'
      ' text'
      <div>'Current count: ' {state.display}</div>
      <Button action={state.decrement}>'-'</Button>
      <Button action={state.increment}>'+'</Button>
    </div>);
  }
}
