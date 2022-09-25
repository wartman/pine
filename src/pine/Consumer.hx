package pine;

import haxe.ds.Option;

@:genericBuild(pine.ConsumerBuilder.buildGeneric())
class Consumer<T> {}

@:deprecated('Use the `from` and `maybeFrom` api instead.')
abstract class ConsumerComponent<T> extends ProxyComponent {
  public final doRender:(value:Option<T>) -> Component;

  abstract function resolve(context:Context):Null<T>;

  public function new(props:{
    render:(value:Option<T>) -> Component,
    ?key:Key
  }) {
    super(props.key);
    doRender = props.render;
  }

  public function render(context:Context):Component {
    return doRender(switch resolve(context) {
      case null: None;
      case value: Some(value);
    });
  }
}
