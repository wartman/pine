package counter;

import js.Browser;
import pine2.*;
import pine2.html.*;
import pine2.html.client.Client;

function main() {
  mount(
    Browser.document.getElementById('root'),
    () -> new Counter({})
  );
}

class Counter extends AutoComponent {
  var count:Int = 0;

  function build() {
    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ 
            'Current count:', 
            new Text(compute(() -> Std.string(count())))
          ]
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
