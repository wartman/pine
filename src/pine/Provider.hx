package pine;

import pine.Disposable;

using Lambda;

class Provider<T:Disposable> implements ViewBuilder {
  @:fromMarkup
  @:noCompletion
  public inline static function fromMarkup<T:Disposable>(props:{
    public final value:T;
    @:children public final views:Children;
  }) {
    return new Provider(props.value).children(props.views);
  }

  public inline static function provide<T:Disposable>(value:T):Provider<T> {
    return new Provider(value);
  } 

  final value:T;
  var views:Children = [];

  public function new(value) {
    this.value = value;
  }

  public function children(...children:Children) {
    views = views.concat(children.toArray().flatten());
    return this;
  }

  public function createView(parent:View, slot:Null<Slot>):View {
    return new ProviderView(parent, parent.adaptor, slot, views, value);
  }
}

class ProviderView<T:Disposable> extends View {
  final value:T;
  final child:View;

  public function new(parent, adaptor, slot, children:Array<ViewBuilder>, value) {
    super(parent, adaptor, slot);
    this.value = value;
    this.child = Fragment.of(children).createView(this, slot);
  }

  override function get<T>(type:Class<T>):Null<T> {
    if (Std.isOfType(value, type)) return cast value;
    return parent.get(type);
  }

  public function findNearestPrimitive():Dynamic {
    return parent.findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    return child.getPrimitive();
  }

  public function getSlot():Null<Slot> {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {
    this.slot = slot;
    child.setSlot(this.slot);
  }

  public function dispose() {
    value.dispose();
    child.dispose();
  }
}
