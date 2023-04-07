package pine2;

import pine2.signal.Signal;

class For<T> extends ProxyComponent {
  final value:Signal<Array<T>>;
  final render:(value:T)->Component;

  public function new(value, render) {
    this.value = value;
    this.render = render;
  }

  function build():Component {
    // @todo: We need to implement a way to reuse values if they
    // don't change -- we should only call `render` if the value
    // is different.
    return new Fragment(compute(() -> value.get().map(render)));
  }
}
