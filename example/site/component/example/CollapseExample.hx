package site.component.example;

import pine.component.*;
import site.component.core.*;

class CollapseExample extends Component {
	function render():Child {
		return Collapse.build({
			child: Panel.build({
				children: [
					ExampleCollapseHeader.build({child: 'Collapse'}),
					ExampleCollapseBody.build({
						children: Html.p().children('Some stuff')
					})
				]
			})
		});
	}
}

class ExampleCollapseHeader extends Component {
	@:attribute final child:Child;

	function render():Child {
		var collapse = CollapseContext.from(this);
		return Html.button()
			.style(Typography.fontWeight('bold'))
			.on(Click, _ -> collapse.toggle())
			.children(
				// `collapse.status` is a Signal, so we can observe it
				// for changes. In a real implementation, this might be
				// where you have a chevron icon rotate or otherwise
				// indicate a collapsed/expanded status.
				child,
				new Computation(() -> switch collapse.status() {
					case Collapsed: ' +';
					case Expanded: ' -';
				})
			);
	}
}

class ExampleCollapseBody extends Component {
	@:attribute final children:Children;

	function render() {
		return CollapseItem.build({
			child: Html.div()
				.style(
					// Note: Setting overflow to 'hidden' is required for
					// the Collapse to work properly.
					Layout.overflow('hidden') // Also setting box-sizing to `border-box` will make things
						// work much better, as the padding will be included in
						// when the Component calculates the size of the element.
						.with(Layout.boxSizing('border'))
				)
				.children(
					Html.div() // Note that we do NOT put the padding in the
						// main collapse target, as this will result in the collapsed
						// element still being visible even if its height is `0`.
						.style(Spacing.pad('15px'))
						.children(children)
				)
		});
	}
}
