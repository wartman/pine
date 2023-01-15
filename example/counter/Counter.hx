package counter;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.debug.html.VisualErrorBoundary;
import pine.html.client.ClientRoot;

function main() {
  ClientRoot.mount(
    Browser.document.getElementById('root'),
    new VisualErrorBoundary({
      child: new Counter({})
    })
  );
}

class Counter extends AutoComponent {
  var count:Int = 0;

  function render(context:Context) {
    // throw 'testing';
    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ ('Current count:':HtmlChild), (count:HtmlChild) ]
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
