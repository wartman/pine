package modifier;

import pine.html.Html;
import pine.signal.Signal;

function style(builder:HtmlTagBuilder, cls:ReadOnlySignal<ClassName>) {
	return builder.attr(ClassName, cls);
}
