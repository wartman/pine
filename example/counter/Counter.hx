package counter;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.Client;

function main() {
  mount(
    Browser.document.getElementById('root'),
    () -> new Counter({})
  );
}

class Counter extends AutoComponent {
  @:signal final count:Int = 0;

  function build() {
    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ 'Current count:', count.map(Std.string) ]
        }),
        new Html<'button'>({
          onclick: _ -> if (count.peek() > 0) count.update(i -> i - 1),
          children: '-'
        }),
        new Html<'button'>({
          onclick: _ -> count.update(i -> i + 1),
          children: '+'
        })
      ]
    });
  }
}
