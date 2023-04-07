package pine2.component;

import pine2.signal.Signal;
import pine2.ObjectComponent.ElementComponent;

class Box extends ElementComponent {
  final attrs:{
    ?className:Signal<String>
  };

  public function new(attrs, children) {
    super(children);
    this.attrs = attrs;
  }

  function getName():String {
    return 'div';
  }

  function getInitialAttrs():{} {
    return {
      'class': attrs.className?.peek()
    };
  }

  function observeAttributeChanges() {
    effect(() -> {
      getAdaptor()?.updateObjectAttribute(getObject(), 'class', attrs.className?.get());
    });
  }
}