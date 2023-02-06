Pine
====

A UI framework for haxe.

> Documentation is in progress.

Getting Started
---------------

Here's an extremely simple app to show how Pine works:

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
  final greeting:String;
  final location:String;

  function render(context:Context) {
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
```

And that's it! When we click on the `+` or `-` buttons, we'll see the count go up or down.

Pine is doing a quite a bit here behind the scenes, however, and it all comes down to this line of code:

```haxe
var count:Int = 0;
```

In an `AutoComponent`, a `final` field is just added to the constructor -- nothing special happens. Mutable fields -- like `var count` here -- are different, and they're converted into a property with a getter and a setter that wrap a `pine.state.Signal<T>`.

Reactivity
----------

Let's pull back a bit and look at what Signals are. Here's a quick example:

```haxe
import pine.state.Signal;
import pine.state.Observer;

function main() { 
  var location = new Signal('world');
  var observer = new Observer(() -> trace('hello ' + location.get()));
  // Immediately traces 'hello world'
  
  location.set('earth');
  // Traces 'hello earth'
  
  location.set('mars');
  // Traces 'hello mars'
}
```

When we call `location.get()` inside the `Observer`, the Observer subscribes to it and will run its handler function every time the Signal changes.

This is basically how Pine is tracking changes in the AutoComponent. It's wrapping in the render method in an Observer, then wrapping each var field in the class with a Signal, and then requests a re-render if any of its subscribed Signals changes. 

> It's actually a bit more complex than that, as Components are designed to change constantly and we need to do some things to ensure that we're not needlessly creating new Observers and Signals, but that's the general idea.

This means that *any* Signal will be subscribed to if its used inside an AutoComponent. Feel free to define Signals anywhere, and your AutoComponent will react to any changes made to them.

```haxe
import js.Browser;
import pine.*;
import pine.html.*;
import pine.state.*;
import pine.html.client.ClientRoot;

final count:Signal<Int> = new Signal(0);

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

Note that Arrays, Maps and anonymous objects get special treatment, again on both AutoComponents and on Records. They aren't simply wrapped in a Signal: instead, they're turned into a `TrackedArray`, `TrackedMap` or `TrackedObject` respectively.

```haxe
import pine.Record;

class Items implements Record {
  var names:Array<String>;
  var locations:Map<String, String>;
  var greeting:{ value:String };
}
```

This is done to ensure reactivity and make sure using Signals feels as natural as possible.

```haxe
import pine.state.*;

function main() {
  // If we didn't use a tracked array, this is how you'd need
  // to make a Signal<Array<String>> reactive:
  var names = new Signal([ 'Bill', 'Alice' ]);
  var obs = new Observer(() -> {
    trace(names.get().join(' '));
  });
  // This won't work:
  names.get().push('Fred');
  // ...you'd have to do this:
  names.set(names.peek().concat([ 'fred' ]));

  // With a TrackedArray, this is much easier:
  var names = new TrackedArray([ 'Bill', 'Alice' ]);
  var obs = new Observer(() -> {
    // We don't even need to call `get()` -- the TrackedArray
    // does that for us. Just treat it like a normal Array!
    trace(names.join(' '));
  });
  // And now this will be reactive:
  names.push('Fred');

  // The same idea applies to TrackedMaps and TrackedObjects.
}
```

Providers and Context
---------------------

> todo: Cover providers and the standard `from`/`maybeFrom` API Pine uses.

Hooks
-----

For the most part, everything you need to do in a UI should be covered by the reactivity described above. You will probably run into edge cases however, situations where you need to synchronize state outside a Pine ui or otherwise cause side effects. For those situations, Pine has a React-inspired `Hook` api you can use.

### useEffect

One difference Pine hooks have from React is that they require you to get an instance from the current Context. For example:

```haxe
class HelloWorld extends AutoComponent {
  var greeting:String;
  var location:String;

  public function render(context:Context) {
    Hook.from(context).useEffect(() -> {
      trace('$greeting $location');
      // We can return an optional cleanup method which will be run
      // once when this Element is disposed.
      return () -> trace('cleanup!');
    });
    return new Html<'div'>({ children: '$greeting $location' });
  }
}
```

Note that, unlike React, we don't need to use a dependency array here. This is because, internally, `useEffect` uses an `Observer`. In the above example, `useEffect` will *only* be triggered if `var greeting` or `var location` change. This may lead to some potentially unexpected behavior: for example, the below example will only ever trigger `useEffect` once, even if the `HelloWorld` component is re-rendered, as no signals are provided to the effect:

```haxe
class HelloWorld extends AutoComponent {
  final greeting:String;
  final location:String;

  public function render(context:Context) {
    Hook.from(context).useEffect(() -> {
      trace('$greeting $location');
      return null;
    });
    return new Html<'div'>({ children: '$greeting $location' });
  }
}
```

> Remember: only `var` fields are converted into signals in `AutoComponent`s.

`useEffect` will only be run *after* an element has finished rendering *and* one of its dependencies has changed. You can use the similar `useObserver` hook to *immediately* run any time one of its dependencies changes without waiting for the component to re-render.

A good rule of thumb is to use `useEffect` if you need to do something with `context` (or otherwise want to be sure that you're waiting until rendering is done) and use `useObserver` if you're just syncing some external data.

### useInit, useUpdate, useNext, and useCleanup

These are fairly self-explanatory. `useInit` will be run *once* after the first time the Element is rendered. `useUpdate` will be run every time the Element is updated, but *not* when it's initialized. The `useNext` hook will be run for both updates *and* when the element is initialized. `useCleanup` adds a hook that will be run when the Element is disposed.

> todo: Cover the other hooks: `useMemo`, `useSignal`, `useObserver`, `useComputed` and `useElement`.
