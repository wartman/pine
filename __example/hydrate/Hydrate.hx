package hydrate;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.Client.hydrate as clientHydrate;
import pine.html.server.Server.mount as mountServer;
import pine.html.server.HtmlElementObject;

function hydrate() {
  // We would never actually do this in a real app -- create the component
  // as a string, insert it into the HTML, and *then* hydrate it --
  // but it should give you an idea of how it all works.

  var root = new HtmlElementObject('div', { id: 'hydrate-root' });
  // Pretend we've created this HTML on a server.
  var html = mountServer(root, () -> new Counter({}));

  var htmlString = (html.getObject():HtmlElementObject).toString();
  
  Browser.document.body.querySelector('#hydrate-display').innerText = htmlString;
  Browser.document.body.querySelector('#hydrate-target').innerHTML = htmlString;

  var jsRoot = Browser.document.getElementById('hydrate-root');

  clientHydrate(jsRoot, () -> new Counter({}));
}

class Counter extends AutoComponent {
  @:signal final count:Int = 0;

  function build() {
    return new Html<'div'>({
      dataset: [
        'fooBar' => 'bar'
      ],
      children: [
        'This is some',
        ' text',
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
