package pine;

using Lambda;

class Provider<T:Disposable> extends Component {
  public inline static function provide<T:Disposable>(value:T) {
    return new ProviderBuilder([ value ]);
  }

  @:attribute final value:T;
  @:children @:attribute var views:Null<Children> = null;

  public function and<T:Disposable>(value:T) {
    return new Provider({ value: value, views: this });
  }

  public function children(children:Children) {
    views = views == null ? children : views.concat(children);
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

abstract ProviderBuilder(Array<Disposable>) {
  public inline function new(providers) {
    this = providers;
  }

  public inline function provide(provider) {
    this.push(provider);
    return abstract;
  }

  public function children(...children:Children):Child {
    var provider = this.shift();
    var child = Provider.build({ value: provider, views: children.toArray().flatten() });
    
    while (provider != null) {
      provider = this.shift();
      var prevChild = child;
      child = Provider.build({ value: provider, views: prevChild });
    }

    return child;
  }

  @:to public inline function toChild():Child {
    return children([]);
  }
}