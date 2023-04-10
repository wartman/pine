package pine2;

import pine2.signal.Signal;

class For<T> extends ProxyComponent {
  final value:ReadonlySignal<Array<T>>;
  final buildItem:(value:T)->Component;

  public function new(value, buildItem) {
    this.value = value;
    this.buildItem = buildItem;
  }

  function build():Component {
    // @todo: We need to implement a way to reuse values if they
    // don't change -- we should only call `buildItem` if the value
    // is different.
    return new Fragment(compute(() -> value().map(buildItem)));
  }
}
