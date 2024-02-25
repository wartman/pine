Pine
====

A simple reactive UI framework for Haxe.

> Note: Probably don't use this right now! The Api is changing
> drastically and constantly.

Usage
-----

Here's an extremely simple app to show how Pine works:

```haxe
import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.*;

function main() {
  var root = Browser.document.getElementById('hydrate-root');
  ClientRoot.hydrate(root, () -> Html.template(<Counter count={0}/>));
}

class Counter extends Component {
  @:signal public final count:Int;
  @:computed public final display:String = Std.string(count());

  public function decrement() {
    if (count() > 0) count.update(i -> i - 1);
  }

  public function increment() {
    count.update(i -> i + 1);
  }

  function render() {
    return Html.template(<div>
      <div>'Current count: ' display</div>
      <button onClick={_ -> decrement()}>'-'</button>
      <button onClick={_ -> increment()}>'+'</button>
    </div>);
  }
}

```

The same app can also be written in pure haxe without using the `Html.template` macro:

```haxe
import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.*;

function main() {
  var root = Browser.document.getElementById('hydrate-root');
  ClientRoot.hydrate(root, () -> Counter.build({ count: 0 }));
}

class Counter extends Component {
  @:signal public final count:Int;
  @:computed public final display:String = Std.string(count());

  public function decrement() {
    if (count() > 0) count.update(i -> i - 1);
  }

  public function increment() {
    count.update(i -> i + 1);
  }

  function render():Child {
    return Html.div().children(
      Html.div().children('Current count: ', display),
      Html.button().on(Click, _ -> decrement()).children('-'),
      Html.button().on(Click, _ -> increment()).children('+'),
    );
  }
}
```

You can use whichever you prefer.

This may look a lot like React, but Pine does *not* use a virtual DOM. Instead, it relies on fine-grained reactivity to keep everything in sync. 

> More details will be coming soon -- right now the API is too in flux for any documentation to stick.
