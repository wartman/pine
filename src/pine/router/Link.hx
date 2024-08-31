package pine.router;

// import kit.http.Request;
import pine.html.Html;

abstract Link(LinkBuilder) {
	public inline static function to(to:String) {
		return new Link(to);
	}

	public inline function new(to:String) {
		this = new LinkBuilder(to);
	}

	public inline function attr(name, value) {
		if (name == 'href') throw 'Invalid attribute: href';
		this.builder.attr(name, value);
		return abstract;
	}

	public inline function on(name, value) {
		this.builder.on(name, value);
		return abstract;
	}

	public inline function children(...views) {
		this.builder.children(...views);
		return abstract;
	}

	@:to public inline function toChild():Child {
		return toView();
	}

	@:to public inline function toChildren():Children {
		return toView();
	}

	@:to public inline function toView() {
		return LinkComponent.build({
			to: this.to,
			builder: this.builder
		});
	}

	public inline function build() {
		return toView();
	}
}

class LinkComponent extends Component {
	@:attribute final to:String;
	@:attribute final builder:HtmlTagBuilder;

	function render() {
		#if pine.client
		var navigator = getContext(Navigator);
		if (navigator != null) {
			builder.on(Click, e -> {
				e.preventDefault();
				navigator.go(new kit.http.Request(Get, to));
			});
		}
		#else
		getContext(RouteVisitor)?.enqueue(to);
		#end

		return builder.attr('href', to).build();
	}
}

@:allow(pine.router.Link)
class LinkBuilder {
	final to:String;
	final builder:HtmlTagBuilder = new HtmlTagBuilder('a');

	public function new(to) {
		this.to = to;
	}
}
