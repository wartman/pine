Pine
====

A simple UI framework.

> Note: Documentation is in progress and is a bit scrambled.

Tracking Changes
----------------

Pine uses a simple reactive framework to track changes to state. Here's a quick example:

```haxe
// `pine.State`s track changes to a given value. 
var greeting = new pine.State('hello');
var location = new pine.State('world');

// `pine.Observer`s will automatically track any `pine.State`s that are used
// inside them whenever `get` is called on a State. In this case,
// `observer` is dependent on `greeting` and `location`.
var observer = new pine.Observer(() -> trace('${greeting.get()} ${location.get()}'));

// `pine.State#set` will cause any `pine.Observer`s that are tracking it to
// be re-computed. Note that this will happen using `Process.defer`, which 
// generally means using `requestAnimationFrame` on any modern browser. This 
// ensures that Pine can batch updates and only trigger the Observers 
// it needs to once. For example, if we set both our states like this:
greeting.set('hey');
location.set('earth');
// ... you will ONLY see `hey earth` traced, not `hey world` and then `hey earth`.
```

You can also create a State that's dependent on other states, which Pine calls a `Computation`:

```haxe
var greeting = new pine.State('hello');
var location = new pine.State('world');
var phrase = new pine.Computation(() -> '${greeting.get()} ${location.get()}');
var observer = new pine.Observer(() -> trace(phrase.get()));

location.set('earth');
```

You can stop an Observer from tracking changes simply by calling `observer.dispose()`.

Note that `pine.ImmutableComponent` WILL NOT track `pine.State`s. You'll need to either use a `pine.Isolate` component in your render method or extend `pine.ObserverComponent` instead of `pine.ImmutableComponent`.

Using an Isolate is simple, and is often the right choice if you only want to make a small part of a Component reactive:

```haxe
package example;

import pine.*;
import pine.html.*;

class HelloWorld extends ImmutableComponent {
  @prop final greeting:State<String>;
  @prop final location:State<String>;

  public function render(context:Context) {
    return new Html<'div'>({
      children: new Isolate({
        wrap: _ -> (greeting.get() + ' ' + location.get():HtmlChild)
      })
    });
  }
}
```

ObserverComponents automatically wrap their render method in an observer, which removes the need for an Isolate:

```haxe
package example;

import pine.*;
import pine.html.*;

class HelloWorld extends ImmutableComponent {
  @prop final greeting:State<String>;
  @prop final location:State<String>;

  public function render(context:Context) {
    return new Html<'div'>({
      children: greeting.get() + ' ' + location.get()
    });
  }
}
```

ObserverComponents can also manage state internally using `@track` meta, which looks like this:

```haxe
package example;

import pine.*;
import pine.html.*;

class HelloWorld extends ImmutableComponent {
  @track var greeting:String;
  @track var location:String;

  public function render(context:Context) {
    return new Html<'div'>({
      children: [
        new Html<'button'>({
          onclick: _ -> {
            greeting = 'hey';
            location = 'earth'
          },
          children: 'Make hey earth'
        }),
        greeting + ' ' + location
      ]
    });
  }
}
```

Note that we don't have to use `set` and `get` with `@track` vars.
