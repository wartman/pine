package pine.component;

import pine.signal.*;

enum abstract LayerContextStatus(Bool) {
	final Showing = true;
	final Hiding = false;
}

@:fallback(new LayerContext())
class LayerContext implements Context {
	public final status:Signal<LayerContextStatus>;

	public function new(?status) {
		this.status = new Signal(status ?? Showing);
	}

	public function hide():Void {
		status.set(Hiding);
	}

	public function show():Void {
		status.set(Showing);
	}

	public function dispose() {}
}
