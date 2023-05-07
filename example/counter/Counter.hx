package counter;

import js.Browser;
import pine.*;
import pine.component.*;
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
    return new Box({
      styles: 'counter',
      children: [
        new Box({
          children: [ 'Current count:', count.map(Std.string) ]
        }),
        new Button({
          onClick: _ -> if (count.peek() > 0) count.update(i -> i - 1),
          children: '-'
        }),
        new Button({
          onClick: _ -> count.update(i -> i + 1),
          children: '+'
        })
      ]
    });
  }
}
