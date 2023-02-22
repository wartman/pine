package counter;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.ClientRoot;

using pine.core.OptionTools;

function main() {
  ClientRoot.mount(
    Browser.document.getElementById('root'),
    new Counter({})
  );
}

class Counter extends AutoComponent {
  var count:Int = 0;

  function render(context:Context) {
    // We can access the actual tracked signals like so:
    trace('Updated with: ${signals.countSignal.peek()}');

    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ 'Current count:', count ]
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
