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

  // Pretend we've created this HTML on a server and sent it
  // to the client:
  var html = ServerRoot.render(() -> Html.template(<div id="hydrate-root">
    <Counter count={0}/>
  </div>));

  Browser.document.body.querySelector('#hydrate-display').innerText = html;
  Browser.document.body.querySelector('#hydrate-target').innerHTML = html;

  var root = Browser.document.getElementById('hydrate-root');
  ClientRoot.hydrate(root, () -> Html.template(<Counter count={0}/>));
}

class Counter extends Component {
  @:signal public final count:Int;
  @:computed public final display:String = Std.string(count());

  public function decrement() {
    if (count() > 0) count.update(i -> i - 1);
  }

  public function increment() {
    count.update(i -> i + 1);
  }

  function render() {
    return Html.template(<div dataset={[ 'fooBar' => 'bar' ]}>
      'This is some'
      ' text'
      <div>'Current count: ' display</div>
      <Button action=decrement>'-'</Button>
      <Button action=increment>'+'</Button>
    </div>);
  }
}
