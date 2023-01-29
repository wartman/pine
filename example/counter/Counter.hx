package counter;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.ClientRoot;

function main() {
  ClientRoot.mount(
    Browser.document.getElementById('root'),
    new Counter({})
  );
}

class Counter extends AutoComponent {
  var count:Int = 0;

  function render(context:Context) {
    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ new Text('Current count:'), Text.ofInt(count) ]
        }),
        new Html<'button'>({
          onclick: _ -> if (count > 0) count--,
          children: '-'
        }),
        new Html<'button'>({
          onclick: _ -> count++,
          children: '+'
        })
      ]
    });
  }
}
