package counter;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.Client;

function counter() {
  mount(
    Browser.document.getElementById('counter-root'),
    () -> new Counter({})
  );
}

class Counter extends AutoComponent {
  @:signal final count:Int = 0;

  function build() {
    return new Html<'div'>({
      className: 'counter',
      children: [
        new Html<'div'>({
          children: [ 'Current count:', count.map(Std.string) ]
        }),
        new Html<'button'>({
          onClick: _ -> if (count.peek() > 0) count.update(i -> i - 1),
          children: '-'
        }),
        new Html<'button'>({
          onClick: _ -> count.update(i -> i + 1),
          children: '+'
        })
      ]
    });
  }
}
