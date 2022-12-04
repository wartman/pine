Pine
====

A UI framework for haxe.

> Documentation is in progress.

Getting Started
---------------

Here's a look at an extremely simple app.

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

The `AutoComponent` does a little bit of magic for us: it takes all our `final` fields and creates a constructor for us. We then us it to create a html `div`, which in turn will display a greeting for us (where again Pine is helpfully converting Strings into pine.html.HtmlTextComponents for us).

Right now isn't too exciting: it'll just display a div with `hello world` in it. What if we want our component to change?

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

In an `AutoComponent`, a `final` field is just added to the constructor -- nothing special happens. Mutable fields -- like `var count` here -- are different, and they're converted into a property with a getter and a setter that wrap a `pine.state.Atom<T>`.

Reactivity
----------

Let's pull back a bit and look at what Atoms are. Here's a quick example:

```haxe
import pine.state.Atom;
import pine.state.Observer;

function main() { 
  var location = new Atom('world');
  var observer = new Observer(() -> trace('hello ' + location.get()));
  // Immediately traces 'hello world'
  
  location.set('earth');
  // Traces 'hello earth'
  
  location.set('mars');
  // Traces 'hello mars'
}
```

When we call `location.get()` inside the `Observer`, the Observer subscribes to it and will run its handler function every time the atom changes.

This is basically how Pine is tracking changes in the AutoComponent. It's wrapping in the render method in an Observer, then wrapping each var field in the class with an Atom, and then requests a re-render if any of its subscribed atoms changes. 

> It's actually a bit more complex than that, as Components are designed to change constantly and we need to do some things to ensure that we're not constantly creating new Observers and Atoms, but that's the general idea.

This means that *any* Atom will be subscribed to if its used inside an `AutoComponent`. For example, we can use a global Atom if we want:

```haxe
import js.Browser;
import pine.*;
import pine.html.*;
import pine.state.*;
import pine.html.client.ClientRoot;

final count:Atom<Int> = new Atom(0);

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

> Do **NOT** create Atoms directly inside render methods. They won't be disposed of properly and all sorts of strange things could happen.

Lifecycles and Hooks
--------------------

> Todo

Records
-------

> Todo
