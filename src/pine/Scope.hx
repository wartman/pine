package pine;

import pine.view.TrackedProxyView;

final class Scope implements ViewBuilder {
  public static inline function wrap(render) {
    return new Scope(render);
  }

  final render:(context:Context)->ViewBuilder;

  public function new(render) {
    this.render = render;
  }

  public function createView(parent:View, slot:Null<Slot>):View {
    return new TrackedProxyView(parent, parent.adaptor, slot, render);
  }
}
