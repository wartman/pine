Pine
====

A UI framework for haxe.

> WARNING: This project is changing constantly right now. It
> is not ready for use in anything remotely serious. 

> Note: Documentation is in progress.

Getting Started
---------------

Here's an extremely simple app to show how Pine works:

```haxe
import pine.*;
import pine.html.*;
import pine.html.client.Client;

function main() {
  mount(
    js.Browser.document.getElementById('root'),
    () -> new HelloWorld({ greeting: 'hello', location: 'world' })
  );
}

class HelloWorld extends AutoComponent {
  final greeting:String;
  final location:String;

  function build() {
    return new Html<'div'>({
      children: '$greeting $location'
    });
  }
}
```

AutoComponent
-------------

Unless you're doing something really complicated, the `AutoComponent` will be the main way you interact with Pine. 

The class does a little bit of macro magic for us to get rid of boilerplate. For starters, we don't need to define a constructor -- instead, the AutoComponent will create one for us using all the classes `final` fields (it does something similar with `var` fields, but more on that in a second). 

To actually render something to the user's screen, we (unsurprisingly) use the `render` method to return other components. Here we're targeting html, so we can use Pine's `html` package and return a `Html<'div'>` with some text content.

Right now this isn't too exciting, and it'll just display a div with `hello world` in it. What if we want our component to change?

Let's look at another example: a simple counter.

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
  var count:Int = 0;

  function build() {
    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ new Text('Current count:'), new Text(count) ]
        }),
        new Html<'button'>({
          onclick: _ -> count.update(i -> if (i > 0) i - 1 else 0),
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
```

And that's it! When we click on the `+` or `-` buttons, we'll see the count go up or down.

Pine is doing a bit behind the scenes, and it all comes down to this line of code:

```haxe
var count:Int = 0;
```

In an `AutoComponent`, a `final` field is just added to the constructor -- nothing special happens. Mutable fields -- like `var count` here -- are different, and they're converted into a `pine.signal.Signal<T>`.

Reactivity
----------

Let's pull back a bit and look at what Signals are. Here's a quick example:

```haxe
import pine.signal.Signal;
import pine.signal.Observer;

function main() { 
  var location = new Signal('world');
  var observer = new Observer(() -> trace('hello ' + location()));
  // Immediately traces 'hello world'
  
  location.set('earth');
  // Traces 'hello earth'
  
  location.set('mars');
  // Traces 'hello mars'
}
```

When we call `location()` (`location.get()` will also work) inside the `Observer`, the Observer subscribes to it and will run its handler function every time the Signal changes.

Unlike frameworks like React, Pine uses *fine-grained* reactivity. A Component's `build` method will only be run once instead of being run every time a value changes. Instead, Pine relies on Signals to directly update attributes and lists of children. For example: 

```haxe
import js.Browser;
import pine.*;
import pine.html.*;
import pine.signal.*;
import pine.html.client.Client;

final count:Signal<Int> = new Signal(0);

function main() {
  Observer.track(() -> trace(count.get()));

  mount(
    Browser.document.getElementById('root'),
    new Counter({})
  );
}

class Counter extends AutoComponent {
  function build() {
    return new Html<'div'>({
      children: [
        new Html<'div'>({
          children: [ 
            new Text('Current count:'),
            // If we pass the `count` signal directly to a `Text` component,
            // it will update the DOM every time `count` changes.
            new Text(count) 
          ]
        }),
        // The `For` component takes a `ReadonlySignal<Array<T>>` (which the
        // `compute` function returns) and iterates over it to create Components.
        //
        // Note that it requires items to be objects to ensure they can be
        // compared -- `For` will only create a new Component if it detects 
        // a new value and will do its best to reuse existing ones.
        new For(
          compute(() -> [ for (i in 0...count()) { value: i } ]),
          i -> new Text(Std.string(i.value))
        ),
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
```

Records
-------

To make global states a bit easer to handle, Pine provides a `Record` interface. It works just like AutoComponents, where `final` fields are added to the constructor and `var` fields become Signals.

```haxe
import pine.Record;

class Greeting implements Record {
  final greeting:String = 'hello';
  var location:String = 'world';
}
```

Incidentally, if you don't want Pine to process your fields, just mark them with `@:skip`. This works for Records and AutoComponents.

```haxe
import pine.Record;

class Greeting implements Record {
  final greeting:String = 'hello';
  // Won't be turned into a Signal:
  @:skip var location:String = 'world';
}
```

> More to come.
