package pine;

import pine.signal.Signal;

class Show extends Component {
  public static inline function when(condition, children) {
    return new Show({
      condition: condition,
      children: children
    });
  }

  public static inline function unless(condition:ReadOnlySignal<Bool>, children) {
    return new Show({
      condition: condition.map(value -> !value), 
      children: children
    });
  }

  @:observable final condition:Bool;
  @:children @:attribute final children:()->View;
  @:attribute var fallback:Null<()->View> = null;

  public function otherwise(fallback) {
    this.fallback = fallback;
    return this;
  }
  
  function render() {
    return Scope.wrap(() -> {
      if (condition()) return children();
      return fallback != null ? fallback() : Placeholder.build();
    });
  }
}
