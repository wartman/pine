package pine.component;

import pine.component.CollapseContext;

class Collapse extends Component {
	@:attribute final initialStatus:CollapseContextStatus = Collapsed;
	@:attribute final duration:Int = 200;
	@:children @:attribute final child:Child;

	function render() {
		var accordion = getContext(AccordionContext);
		return Provider
			.provide(new CollapseContext(initialStatus, duration, accordion))
			.children(child);
	}
}
