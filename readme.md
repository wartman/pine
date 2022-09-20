Pine
====

A simple UI framework.

> Note: Documentation is in progress and is a bit scrambled.

Context and Providers 
---------------------

Sharing state across a component tree can be a pain. You could just pass attributes down to child components:

```haxe
class ComponentA extends ImmutableComponent {
  @prop final foo:String;

  function render(context:Context) {
    return new ComponentB({ foo: foo });
  }
}

class ComponentB extends ImmutableComponent {
  @prop final foo:String;

  function render(context:Context) {
    return new ComponentC({ foo: foo });
  }
}

class ComponentC extends ImmutableComponent {
  @prop final foo:String;

  function render(context:Context) {
    return new Html<'text'>({ content: foo });
  }
}
```

...but that can get complicated quickly.

To solve this problem, Pine stole an idea from Flutter. All render methods have a `context` argument which allows you to hook into the current Element tree. This can let you do things like search for ancestor or child elements, access the current render object, etc. Right now, what we care about is how it hooks into the Provider system.

```haxe
typedef FooProvider = Provider<String>;

class ComponentA extends ImmutableComponent {
  @prop final foo:String;

  function render(context:Context) {
    return new FooProvider({
      create: () -> 'foo',
      // We don't need to dispose anything for this example, but `dispose`
      // is required for all providers.
      dispose: value -> null, 
      render: _ -> new ComponentB({})
    });
  }
}

class ComponentB extends ImmutableComponent {
  function render(context:Context) {
    return new ComponentC({});
  }
}

class ComponentC extends ImmutableComponent {
  function render(context:Context) {
    return new Html<'text'>({ content: FooProvider.from(context) });
  }
}
```

In the above example, `FooProvider.from(context)` will search up the Element tree until it finds the `FooProvider` component, returning the value we created there.

This works great, but you can run into issues if you use `FooProvider.from(context)` in a scenario where there is no parent `FooProvider`. There are a few ways to solve this: you could check if `FooProvider.from(context)` returns null, or you might use `maybeFrom`:

```haxe
class ComponentC extends ImmutableComponent {
  function render(context:Context) {
    return new Html<'text'>({ content: switch FooProvider.maybeFrom(context) {
      case Some(foo): foo;
      case None: 'default';
    } });
  }
}
```

You might also consider using a `pine.Service`, which enforces defaults:

```haxe
@default(new FooService('foo'))
class FooService implements Service {
  public final foo:String;

  public function new(foo) {
    this.foo = foo;
  }

  public function dispose() {
    trace('disposed');
  }
}
```

If no `FooService` is provided, `FooService.from(context)` will return the expression set in `@default`.

```haxe
class ComponentC extends ImmutableComponent {
  function render(context:Context) {
    return new Html<'text'>({ content: FooService.from(context).foo });
  }
}
```

In addition, `Services` have a handy `provide` shortcut you can use:

```haxe
class ComponentA extends ImmutableComponent {
  @prop final foo:String;

  function render(context:Context) {
    return FooService.provider(
      new FooService(foo),
      service -> new ComponentB({})
    );
  }
}
```

...although `new Provider<FooService>({ ... })` will also work, just with a little more boilerplate.

Generally, best practice is to use `maybeFrom` with all providers unless you're using a `pine.Service`.

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
