package pine.html;

import pine.html.HtmlEvents;
import pine.signal.Signal;

using Lambda;

@:build(pine.html.HtmlBuilder.build())
class Html {
	public macro static function view(e);

	public static inline function build(tag:String) {
		return new HtmlTagBuilder(tag);
	}
}

@:forward
abstract HtmlTagBuilder(HtmlTagBuilderImpl) from HtmlTagBuilderImpl {
	public inline function new(tag) {
		this = new HtmlTagBuilderImpl(tag);
	}

	@:to public inline function toView():View {
		return this.build();
	}

	@:to public inline function toChild():Child {
		return this.build();
	}

	@:to public inline function toChildren():Children {
		return this.build();
	}
}

class HtmlTagBuilderImpl {
	final tag:String;
	final attributes:Map<String, ReadOnlySignal<Dynamic>> = [];

	var views:Children = [];
	var refCallback:Null<(primitive:Dynamic) -> Void> = null;

	public function new(tag) {
		this.tag = tag;
	}

	public function attr(name:HtmlAttributeName, value:ReadOnlySignal<Dynamic>):HtmlTagBuilder {
		// @todo: Something better than this:
		if (attributes.exists(name) && name == 'class') {
			var prev = attributes.get(name);
			attributes.set(name, prev.map(prev -> prev + ' ' + value()));
			return this;
		}

		attributes.set(name, value);
		return this;
	}

	public function on(event:HtmlEventName, value:ReadOnlySignal<EventListener>):HtmlTagBuilder {
		attributes.set('on' + event, value);
		return this;
	}

	public function ref(cb):HtmlTagBuilder {
		refCallback = cb;
		return this;
	}

	public function children(...views:Children):HtmlTagBuilder {
		this.views = this.views.concat(views.toArray().flatten());
		return this;
	}

	public function build():View {
		return new PrimitiveView(
			tag,
			attributes,
			views,
			refCallback
		);
	}
}
