We want something like what [Solid](https://github.com/ryansolid/dom-expressions/tree/main/packages/babel-plugin-jsx-dom-expressions) does.

The idea here is to take code like this:

```haxe
function render(_) {
  return Html.template(<div class={foo}>
    <p>"Hello world!" {foo}</p>
    <Button onClick={_ -> trace('yay!')}>"Click for " {label}</Button>
    <p>"Bye world"</p>
  </div>);
}
```

...and turn it into something like this:

```haxe
function render(_) {
  static template = new HtmlTemplate('<div><p>Hello World! ></p><p>Bye world</p></div>');
  return new HtmlTemplateView(template.clone(), (tpl, el) -> {
    // Create a list of all static elements. These are tracked during
    // compilation, so we'll know where to insert things.
    var el0 = el.firstChild; // <- <p>
    var el0_0 = el0.firstChild; // <- "Hello world! "
    var el1 = el0.nextSibling; // <- <p>
  
    // Track any dynamic attributes.
    Observer.track(() -> el.setAttribute('class', foo()));
  
    // Build all non-static components.
    var builder0 = Text.ofString(foo);
    var view0 = builder0.createView(tpl, tpl.adaptor, new Slot(0, el0_0));

    var builder1 = Button.build({ 
      onClick: _ -> trace('yay!'),
      children: [
        Text.ofString("Click for "),
        label
      ]
    });
    var view1 = builder1.createView(tpl, tpl.adaptor, new Slot(1, e11));
    
    // Return a list of disposables for cleanup:
    return [view0, view1];
  });
}
```

A completely different approach will be needed for CSR stuff, so we'll have to think about the best way to do things. This may require my favorite thing: an abstraction layer. Note that CSR stuff will benefit from this too, as making all static HTML just a string would be great.

Maybe instead of `el` we return a cursor? And, for static targets, we include some simple comments for insertion points?

```haxe
function render(_) {
  static __template$0 = this.adaptor.createTemplate('<div><p>Hello World! <!--@SLOT-->></p><!--@SLOT--><p>Bye world</p></div>');
  return new HtmlTemplateView(__template$0.clone(), (tpl, cursor) -> {
    var adaptor = tpl.adaptor;
    var el = cursor.current();
    var cursor_child = cursor.child();
    var el0 = cursor_child.current();
    var cursor_child_child = cursor_child.child();
    var el0_0 = cursor_child_child.current();
    cursor_child.next();
    var el1 = cursor_child.current();
  
    Observer.track(() -> {
      adaptor.updatePrimitiveAttribute(el, 'class', foo());
    });
  
    var builder0 = Text.ofString(foo);
    var view0 = builder0.createView(tpl, adaptor, new Slot(0, el0_0));

    var builder1 = Button.build({ 
      onClick: _ -> trace('yay!'),
      children: [
        Text.ofString("Click for "),
        label
      ]
    });
    var view1 = builder1.createView(tpl, adaptor, new Slot(1, e11));

    return [view0, view1];
  });
}
```

That could do it!

Note that we'll also have to figure out how to do some type checking for HTML attributes, but we can get there.
