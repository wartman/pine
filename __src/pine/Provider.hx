package pine;

import pine.debug.Debug;

@:genericBuild(pine.macro.ProviderBuilder.buildGeneric())
class Provider<T> {}

abstract class ProviderComponent<T> extends AutoComponent {
  final childWithValue:(value:T)->Component;
  final disposeOfValue:(value:T)->Void;
  var value:Null<T> = null;

  public function new(props:{
    value:T,
    child:(value:T) -> Component,
    dispose:(value:T) -> Void,
  }) {
    this.value = props.value;
    this.childWithValue = props.child;
    this.disposeOfValue = props.dispose;
  }

  public function getValue():Null<T> {
    return value;
  }

  public function build() {
    assert(value != null);
    return childWithValue(value);
  }

  override function dispose() {
    if (value != null) {
      disposeOfValue(value);
      value = null;
    }
    super.dispose();
  }
}
