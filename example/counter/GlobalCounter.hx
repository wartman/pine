package counter;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.signal.*;
import pine.html.client.Client;

final count:Signal<Int> = new Signal(0);

function globalCounter() {
  Observer.track(() -> trace(count.get()));

  mount(
    Browser.document.getElementById('global-counter-root'),
    () -> new GlobalCounter({})
  );
}

class GlobalCounter extends AutoComponent {
  function build() {
    return new Html<'div'>({
      children: [
        new Html<'h3'>({
          children: 'Global Counter'
        }),
        new Html<'div'>({
          children: [ 'Current count:', count.map(Std.string) ]
        }),
        new Html<'button'>({
          onClick: _ -> if (count.peek() > 0) count.set(count.peek() - 1),
          children: '-'
        }),
        new Html<'button'>({
          onClick: _ -> count.set(count.peek() + 1),
          children: '+'
        })
      ]
    });
  }
}
