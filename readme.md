Pine
====

A reactive UI framework for Haxe.

> WARNING: This project is changing constantly right now. It
> is not ready for use in anything remotely serious. 

> Note: Documentation is in progress.

Getting Started
---------------

Here's an extremely simple app to show how Pine works:

```haxe
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
```

This may look somewhat like Flutter or even a little like React, but Pine does *not* use a virtual DOM. Instead, it relies on fine-grained reactivity to keep everything in sync. 

> More details will be coming soon -- right now the API is too in flux for any documentation to stick.
