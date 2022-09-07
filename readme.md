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
// be re-computed.
greeting.set('hey');
location.set('earth');

// Note that the above will cause the observer to be recomputed *twice*.
// To batch changes, use a `pine.Action`:
var action = new Action(() -> {
  greeting.set('hey');
  location.set('earth');
});

// ...then call the action to notify the observers:
action();
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

class HelloWorld extends ObserverComponent {
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

class HelloWorld extends ObserverComponent {
  @track var greeting:String;
  @track var location:String;

  public function render(context:Context) {
    return new Html<'div'>({
      children: [
        new Html<'button'>({
          onclick: _ -> {
            greeting = 'hey';
            location = 'earth';
          },
          children: 'Make hey earth'
        }),
        greeting + ' ' + location
      ]
    });
  }
}
```

Note that we don't have to use `set` and `get` with `@track` vars -- a macro will convert them into properties with getters and setters to handle that for you.

In all of the above examples, simply changing a State (such as in the `onclick` handler in the `Html<'button'>`) is all you need to do to invalidate a component and cause it to re-render. No special syntax or `setState` needed -- you can just write code like you would if it wasn't reactive and Pine will track things for you.

> Note: More documentation on the way.
