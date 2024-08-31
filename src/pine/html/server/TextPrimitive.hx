package pine.html.server;

import pine.Constants;
import pine.html.server.Primitive;

using StringTools;

class TextPrimitive extends Primitive {
	var content:String;

	public function new(content) {
		this.content = content;
	}

	public function updateContent(content) {
		if (content == null) content = '';
		this.content = content;
	}

	public function toString(?options:PrimitiveStringifyOptions):String {
		// Important: we prefix all strings with a comment to ensure
		// that text components are split up during hydration. On the
		// client side comments will be ignored, but should still ensure
		// text nodes are properly delimited.
		//
		// This can be turned off via the `useMarkers` option.
		var raw = options?.useMarkers(this) ?? true;
		return raw ? '<!--${TextMarker}-->' + content.htmlEscape() : content;
	}
}
