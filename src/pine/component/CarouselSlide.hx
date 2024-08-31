package pine.component;

import pine.html.Html;

typedef CarouselSlideFactory = (context:CarouselContext) -> Child;

abstract CarouselSlide(CarouselSlideFactory) from CarouselSlideFactory to CarouselSlideFactory {
	public static inline function wrap(factory) {
		return new CarouselSlide(factory);
	}

	public inline function new(factory) {
		this = factory;
	}

	public inline function build(position:Int) {
		return CarouselSlideViewport.build({
			position: position,
			child: this
		});
	}
}

class CarouselSlideViewport extends Component {
	@:attribute public final position:Int;

	@:children @:attribute final child:(carousel:CarouselContext) -> Child;

	function render():Child {
		var carousel = CarouselContext.from(this);
		var body = if (carousel.options.onlyShowActiveSlides) Scope.wrap(_ -> {
			var pos = carousel.getPosition();
			return if (pos.current - 1 == position || pos.current == position || pos.current + 1 == position) {
				child(carousel);
			} else {
				Placeholder.build();
			}
		}) else child(carousel);

		return Html.div()
			.attr(Style, 'flex:0 0 100%')
			.children(body);
	}
}
