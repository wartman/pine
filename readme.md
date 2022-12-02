Pine
====

A UI framework for haxe.

> Documentation is in progress.

Getting Started
---------------

Let's look at an extremely simple app first.

```haxe
import pine.*;
import pine.html.*;
import pine.html.client.ClientRoot;

function main() {
  ClientRoot.mount(
    js.Browser.document.getElementById('root'),
    new HelloWorld({ greeting: 'hello', location: 'world' })
  );
}

class HelloWorld extends AutoComponent {
  @:prop final greeting:String;
  @:prop final location:String;

  function render(context:Context) {
    return new Html<'div'>({
      children: '$greeting $location'
    });
  }
}
```

> More to come.
