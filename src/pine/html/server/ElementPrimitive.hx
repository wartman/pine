package pine.html.server;

import pine.html.server.Primitive.PrimitiveStringifyOptions;
import haxe.DynamicAccess;

class ElementPrimitive extends Primitive {
	static final VOID_ELEMENTS = [
		'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr',
	];

	public final tag:String;
	public final attributes:{};
	public final classList:List<String> = new List();

	public function new(tag, attributes) {
		this.tag = tag;
		this.attributes = attributes;
	}

	public function setAttribute(name:String, value:Dynamic) {
		if (name == 'dataset') {
			var dataset = Reflect.field(attributes, 'dataset');
			if (dataset == null) {
				dataset = {};
			}
			for (key => value in (value : Map<String, String>)) {
				if (value != null) Reflect.setField(attributes, 'data-$key', value);
			}
			return;
		}
		Reflect.setField(attributes, name, value);
	}

	public function toString(?options:PrimitiveStringifyOptions):String {
		var attrs:Map<String, String> = getFilteredAttributes();
		var children:Array<String> = children
			.filter(c -> c != null)
			.map(c -> c.toString(options));

		if (tag == '#document' || tag == '#fragment') {
			return children.join('');
		}

		var tag = switch tag.split(':') {
			case [_, name]: name;
			default: tag;
		}

		var out = '<${tag}';
		var attrs = [for (key => value in attrs) '$key="$value"'];
		if (attrs.length > 0) out += ' ${attrs.join(' ')}';

		// todo: handle innerHTML.

		return if (VOID_ELEMENTS.contains(tag)) {
			out + '/>';
		} else if (children.length > 0) {
			out + '>' + children.join('') + '</${tag}>';
		} else {
			out + '></${tag}>';
		}
	}

	@:nullSafety(Off)
	function getFilteredAttributes():Map<String, String> {
		var attrs:DynamicAccess<Dynamic> = attributes;
		var out:Map<String, String> = [];

		for (key => value in attrs) {
			if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
				// noop
			} else if (Reflect.isFunction(value)) {
				// noop
			} else if (value == null || value == false) {
				// noop
			} else if (key == 'className') {
				out.set('class', value);
			} else if (key == 'dataset') {
				for (name => value in (value : Map<String, String>)) {
					out.set('data-${kebabCase(name)}', value);
				}
			} else if (value == true) {
				out.set(key, key);
			} else {
				out.set(key, Std.string(value));
			}
		}

		if (classList.length > 0) {
			switch out.get('class') {
				case null: out.set('class', classList.join(' '));
				case value: out.set('class', value + ' ' + classList.join(' '));
			}
		}

		return out;
	}
}

// @todo: Probably should just use a RegExp here but whatever.
function kebabCase(str:String) {
	var out = '';
	var i = 0;
	while (i < str.length) {
		var c = str.charAt(i++);
		if (c > 'A' && c < 'Z') {
			out += '-' + c.toLowerCase();
		} else {
			out += c;
		}
	}
	return out;
}
