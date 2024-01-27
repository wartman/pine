package pine;

using Lambda;

class Provider<T:Disposable> extends Component {
  public inline static function provide<T:Disposable>(value:T):Provider<T> {
    return new Provider({ value: value });
  }

  @:attribute final value:T;
  @:children @:attribute var views:Null<Children> = [];

  public function children(...children:Children) {
    views = views.concat(children?.toArray()?.flatten() ?? []);
    return this;
  }

  function render():Child {
    return views != null ? Fragment.of(views) : Placeholder.build();
  }

  override function get<T>(type:Class<T>):Null<T> {
    if (Std.isOfType(value, type)) return cast value;
    return getParent()?.get(type);
  }

  override function __dispose() {
    value.dispose();
    super.__dispose();
  }
}
