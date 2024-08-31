package pine.html;

import haxe.macro.Context;
import kit.macro.ClassFieldCollection;

function build() {
	var fields = new ClassFieldCollection(Context.getBuildFields());
	var tagFields = extractTags('pine.html.HtmlTags')
		.concat(extractTags('pine.html.SvgTags'));

	for (tag in tagFields) {
		var name = tag.name;
		var tagName = if (tag.meta.has(':svg')) 'svg:' + name else name;
		fields.add(macro class {
			public static inline function $name() {
				return build($v{tagName});
			}
		});
	}

	return fields.export();
}

private function extractTags(typeName:String) {
	var tags = Context.getType(typeName);
	return switch tags {
		case TType(t, _): switch t.get().type {
				case TAnonymous(a): a.get().fields;
				default: throw 'assert';
			}
		default: throw 'assert';
	}
}
