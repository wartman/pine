package pine;

import pine.signal.Signal;

class For<T:{}> extends ProxyComponent {
  final value:ReadonlySignal<Array<T>>;
  final buildItem:(value:T)->Component;

  public function new(value, buildItem) {
    this.value = value;
    this.buildItem = buildItem;
  }

  function build():Component {
    // @todo: We may need to do more to ensure
    // this all works, but this seems to be OK for now.
    //
    // Basically this takes care of what `keys` typically
    // do in VDom based frameworks. In our `compute` all
    // we need to worry about is checking if a component
    // already exists for a value and returning it 
    // in the right order -- the Fragment will then
    // move the components around as needed.
    var existing:Map<T, Component> = [];
    addDisposable(() -> existing.clear());

    return new Fragment(compute(() -> {
      var items = value();
      var toRemove:Array<T> = [ for (key in existing.keys()) key ];
      var next:Array<Component> = [ for (item in items) {
        toRemove.remove(item);
        var comp = existing.get(item);
        if (comp == null) {
          comp = buildItem(item);
          existing.set(item, comp);
          comp;
        }
        comp;
      } ];

      for (item in toRemove) {
        existing.remove(item);
      }

      next;
    }));
  }
}
