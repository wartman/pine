package pine2;

import kit.Assert;

@:genericBuild(pine2.ProviderBuilder.buildGeneric())
class Provider<T> {}

abstract class ProviderComponent<T> extends ProxyComponent {
  final create:()->T;
  final buildWithValue:(value:T)->Component;
  final disposeOfValue:(value:T)->Void;
  var value:Null<T> = null;

  public function new(props:{
    create:() -> T,
    build:(value:T) -> Component,
    dispose:(value:T) -> Void,
  }) {
    this.create = props.create;
    this.buildWithValue = props.build;
    this.disposeOfValue = props.dispose;
  }

  public function getValue():Null<T> {
    return value;
  }

  public function build() {
    assert(value == null);
    value = create();
    return buildWithValue(value);
  }

  override function dispose() {
    disposeOfValue(value);
    value = null;
    super.dispose();
  }
}
