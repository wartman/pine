package pine;

import pine.debug.Debug;
import pine.signal.Signal;
import pine.signal.Computation;

class Each<T:{}> extends AutoComponent {
  final value:ReadonlySignal<Array<T>>;
  final buildItem:(value:T)->Component;

  public function new(value, buildItem) {
    this.value = value;
    this.buildItem = buildItem;
  }

  function build():Component {
    var existing:Map<T, Component> = [];
    addDisposable(() -> existing.clear());

    var children = new Computation(() -> {
      var items = value();

      // Forget any components that don't have an associated item.
      for (item => _ in existing) {
        // Note: we don't want to dispose of any components here!
        // All we want to do is return an array of current components.
        // The Fragment is in charge of actually reconciling everything.
        if (!items.contains(item)) existing.remove(item);
      }

      // Loop through our items, reusing Components if possible.
      var next:Array<Component> = [];
      for (item in items) {
        var comp = existing.get(item);
        if (comp == null) {
          comp = buildItem(item);
          existing.set(item, comp);
        }
        assert(!next.contains(comp), 'A component was used more than once');
        next.push(comp);
      }

      next;
    });
    addDisposable(children);

    return new Fragment(children);
  }
}
