package pine;

import pine.internal.Debug;

@:genericBuild(pine.ProviderBuilder.buildGeneric())
class Provider<T> {}

abstract class ProviderComponent<T> extends ProxyComponent {
  final buildWithValue:(value:T)->Component;
  final disposeOfValue:(value:T)->Void;
  var value:Null<T> = null;

  public function new(props:{
    value:T,
    build:(value:T) -> Component,
    dispose:(value:T) -> Void,
  }) {
    this.value = props.value;
    this.buildWithValue = props.build;
    this.disposeOfValue = props.dispose;
  }

  public function getValue():Null<T> {
    return value;
  }

  public function build() {
    assert(value != null);
    return buildWithValue(value);
  }

  override function dispose() {
    if (value != null) {
      disposeOfValue(value);
      value = null;
    }
    super.dispose();
  }
}
