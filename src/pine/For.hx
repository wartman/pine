package pine;

import pine.view.IteratorView;
import pine.signal.Signal.ReadOnlySignal;

class For<T:{}> implements ViewBuilder {
  @:fromMarkup
  @:noCompletion
  public inline static function fromMarkup<T:{}>(props:{
    public final each:ReadOnlySignal<Array<T>>;
    @:children public final child:(item:T)->Child;
  }) {
    return For.each(props.each, props.child);
  }

  public static inline function each<T:{}>(items, render) {
    return new For<T>(items, render);
  }

  final items:ReadOnlySignal<Array<T>>;
  final render:(item:T)->Child;

  public function new(items, render) {
    this.items = items;
    this.render = render;
  }

  public function createView(parent:View, slot:Null<Slot>):View {
    return new IteratorView(
      parent,
      parent.adaptor,
      slot,
      items,
      render
    );
  }
}