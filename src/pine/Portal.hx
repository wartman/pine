package pine;

class Portal extends View {
	@:fromMarkup
	@:noCompletion
	@:noUsing
	public inline static function fromMarkup(props:{
		public final target:Dynamic;
		@:children public final child:() -> Child;
	}) {
		return new Portal(props.target, props.child);
	}

	public inline static function into(target, child) {
		return new Portal(target, child);
	}

	final target:Dynamic;

	var child:() -> View;
	var root:Null<View> = null;
	var marker:Null<View> = null;

	public function new(target, child) {
		this.target = target;
		this.child = child;
	}

	function __initialize() {
		var adaptor = getAdaptor();

		marker = Placeholder.build();
		marker.mount(this, adaptor, slot);

		// @todo: How should this handle hydration?
		root = Root.build(target, adaptor, child).create(this);
	}

	public function findNearestPrimitive():Dynamic {
		return marker?.getPrimitive();
	}

	public function getPrimitive():Dynamic {
		return marker?.getPrimitive();
	}

	function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>) {
		marker?.setSlot(newSlot);
	}

	function __dispose() {
		root?.dispose();
		marker?.dispose();
	}
}
