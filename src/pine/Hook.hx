package pine;

/**
  A `Hook` is an escape hatch provided by Pine to give you more
  access to an Element's lifecycle. Generally you won't need this
  functionality.

  `AutoComponent` provides a convenient way to add hooks: simply
  use `@:hook` class meta and pass in a function. For example:
    
  ```haxe
  @:hook(element -> trace(element))
  class Foo extends AutoComponent {
    // ... code here
  }
  ```

  Pine comes with a few pre-made hooks in `pine.CoreHooks` that should
  cover most of the things you'll need (such as watching every time an
  Element updates), and you can also look there to get a better idea of 
  how they work.
**/
typedef Hook<T:Component> = (element:ElementOf<T>) -> Void;
