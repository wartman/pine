package pine.component;

import pine.component.CarouselSlide;
import pine.debug.Debug;
import pine.signal.Signal;

typedef CarouselContextOptions = {
	public final onlyShowActiveSlides:Bool;
}

@:fallback(error('No CarouselContext found'))
class CarouselContext implements Context {
	public final options:CarouselContextOptions;
	public final count:Int;
	public final slides:Array<CarouselSlideViewport>;

	final index:Signal<Int>;

	var previousIndex:Int;

	public function new(slides, index, ?options:CarouselContextOptions) {
		this.slides = slides;
		this.count = slides.length;
		this.index = new Signal(index);
		this.previousIndex = index;
		this.options = options == null ? {onlyShowActiveSlides: false} : options;
	}

	public function getPosition():{current:Int, previous:Int} {
		return {
			current: index(),
			previous: previousIndex
		};
	}

	public function hasNext() {
		return index.peek() < (count - 1);
	}

	public function hasPrevious() {
		return index.peek() > 0;
	}

	public function next() {
		index.update(index -> {
			var next = index + 1;
			if (next > count - 1) return index;
			previousIndex = index;
			return next;
		});
	}

	public function previous() {
		index.update(index -> {
			var prev = index - 1;
			if (prev < 0) return index;
			previousIndex = index;
			return prev;
		});
	}

	public function dispose() {}
}
