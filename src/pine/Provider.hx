package pine;

using Lambda;

// @todo: Consider only allowing Providers to provide Context. I was
// providing Components here, but that causes endless loops at disposal
// time.
class Provider<T:Disposable> extends Component {
	public inline static function provide<T:Disposable>(value:T) {
		return new ProviderBuilder([value]);
	}

	@:attribute final value:T;
	@:children @:attribute var views:Null<Children> = null;

	public function children(children:Children) {
		views = views == null ? children : views.concat(children);
		return this;
	}

	function render():Child {
		return switch views.toArray() {
			case []: Placeholder.build();
			case [view]: view;
			default: Fragment.of(views);
		}
	}

	override function getContext<T>(type:Class<T>):Null<T> {
		if (Std.isOfType(value, type)) return cast value;
		return getParent()?.getContext(type);
	}

	override function __dispose() {
		value.dispose();
		super.__dispose();
	}
}

abstract ProviderBuilder(Array<Disposable>) {
	public inline function new(values) {
		this = values;
	}

	public inline function provide(value) {
		this.push(value);
		return abstract;
	}

	public function children(children:Children):Child {
		var value = this.shift();
		var child = Provider.build({value: value, views: children});
		value = this.shift();

		while (value != null) {
			var prevChild = child;
			child = Provider.build({value: value, views: prevChild});
			value = this.shift();
		}

		return child;
	}

	@:to public inline function toChild():Child {
		return build();
	}

	public inline function build():View {
		return children([]);
	}
}
