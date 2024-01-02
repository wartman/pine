package counter;

import js.Browser;
import pine.*;
import pine.Disposable;
import pine.html.*;
import pine.html.client.Client;
import pine.signal.*;

final count:Signal<Int> = new Signal(0);

function globalCounter() {
  // Note: We need to set an owner (which is a `DisposableHost`)
  // in order to ensure `Observer.track` doesn't give us a warning.
  //
  // We could, in theory, then hook up this collection to dispose 
  // when the window closes or something, but that's really not needed.
  //
  // @todo: we might improve this behavior beyond Owners just being 
  // DisposableHosts. We may also, for example, handle errors with them.
  var root = new DisposableCollection();
  Graph.withOwner(root, () -> {
    Observer.track(() -> trace(count.get()));
  });

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
