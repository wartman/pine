package counter;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.state.*;
import pine.html.client.ClientRoot;

final count:Atom<Int> = new Atom(0);

function main() {
  Observer.track(() -> trace(count.get()));

  ClientRoot.mount(
    Browser.document.getElementById('root'),
    new Counter({})
  );
}

class Counter extends AutoComponent {
  function render(context:Context) {
    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ ('Current count:':HtmlChild), (count.get():HtmlChild) ]
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
