package pine;

import pine.debug.Debug;

enum ViewStatus {
	Pending;
	Mounted(parent:Null<View>, adaptor:Adaptor);
	Disposed;
}

abstract class View implements Disposable {
	var __status:ViewStatus = Pending;
	var slot:Null<Slot> = null;

	public function mount(parent, adaptor, slot) {
		assert(__status == Pending);
		__status = Mounted(parent, adaptor);
		this.slot = slot;
		__initialize();
	}

	abstract function __initialize():Void;

	public function getContext<T>(type:Class<T>):Null<T> {
		return getParent()?.getContext(type);
	}

	public function getParent() {
		return switch __status {
			case Mounted(parent, _):
				parent;
			default:
				error('Attempted to get a parent from an unmounted or disposed view');
		}
	}

	public function getAdaptor() {
		return switch __status {
			case Mounted(_, adaptor):
				adaptor;
			default:
				error('Attempted to get an adaptor from an unmounted or disposed view');
		}
	}

	abstract public function findNearestPrimitive():Dynamic;

	abstract public function getPrimitive():Dynamic;

	public function getSlot():Null<Slot> {
		return slot;
	}

	public function setSlot(slot:Null<Slot>):Void {
		var previousSlot = this.slot;
		this.slot = slot;
		__updateSlot(previousSlot, this.slot);
	}

	abstract function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>):Void;

	public function dispose() {
		if (__status == Disposed) return;

		__dispose();
		__status = Disposed;
	}

	abstract function __dispose():Void;
}
