package pine.html.server;

import pine.debug.Debug;

typedef PrimitiveStringifyOptions = {
	public final useMarkers:(primitive:Primitive) -> Bool;
}

abstract class Primitive {
	public var parent:Null<Primitive> = null;
	public var children:Array<Primitive> = [];

	public function prepend(child:Primitive) {
		assert(child != this);

		if (child.parent != null) child.remove();

		child.parent = this;
		children.unshift(child);
	}

	public function append(child:Primitive) {
		assert(child != this);

		if (child.parent != null) child.remove();

		child.parent = this;
		children.push(child);
	}

	public function insert(pos:Int, child:Primitive) {
		assert(child != this);

		if (child.parent != this && child.parent != null) child.remove();

		child.parent = this;

		if (!children.contains(child)) {
			children.insert(pos, child);
			return;
		}

		if (pos >= children.length) {
			pos = children.length;
		}

		var from = children.indexOf(child);

		if (pos == from) return;

		if (from < pos) {
			var i = from;
			while (i < pos) {
				children[i] = children[i + 1];
				i++;
			}
		} else {
			var i = from;
			while (i > pos) {
				children[i] = children[i - 1];
				i--;
			}
		}

		children[pos] = child;
	}

	public function remove() {
		if (parent != null) {
			parent.children.remove(this);
		}
		parent = null;
	}

	abstract public function toString(?options:PrimitiveStringifyOptions):String;
}
