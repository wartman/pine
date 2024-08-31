package pine;

import pine.signal.Signal;

class Show extends Component {
	public static inline function when(condition, children) {
		return new ShowBuilder(condition, children);
	}

	public static inline function unless(condition:ReadOnlySignal<Bool>, children) {
		return new ShowBuilder(condition.map(value -> !value), children);
	}

	@:observable final condition:Bool;
	@:children @:attribute final children:() -> View;
	@:attribute var fallback:Null<() -> View> = null;

	function render() {
		return Scope.wrap(() -> {
			if (condition()) return children();
			return fallback != null ? fallback() : Placeholder.build();
		});
	}
}

abstract ShowBuilder({
	final condition:ReadOnlySignal<Bool>;
	final children:() -> Child;
	var ?fallback:() -> Child;
}) {
	public inline function new(condition, children) {
		this = {
			condition: condition,
			children: children
		};
	}

	public function otherwise(fallback) {
		this.fallback = fallback;
		return abstract;
	}

	@:to public inline function build() {
		return new Show({
			condition: this.condition,
			children: this.children,
			fallback: this.fallback
		});
	}
}
