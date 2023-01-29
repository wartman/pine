package counter;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.state.*;
import pine.html.client.ClientRoot;

final count:Signal<Int> = new Signal(0);

function main() {
  Observer.track(() -> trace(count.get()));

  ClientRoot.mount(
    Browser.document.getElementById('root'),
    new GlobalCounter({})
  );
}

class GlobalCounter extends AutoComponent {
  function render(context:Context) {
    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ new Text('Current count:'), Text.ofInt(count.get()) ]
        }),
        new Html<'button'>({
          onclick: _ -> if (count.peek() > 0) count.set(count.peek() - 1),
          children: '-'
        }),
        new Html<'button'>({
          onclick: _ -> count.set(count.peek() + 1),
          children: '+'
        })
      ]
    });
  }
}
