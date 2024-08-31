package site.island;

import site.component.core.Button;
import pine.bridge.Island;
import pine.component.*;
import site.data.*;

class DropdownMenu extends Island {
	@:attribute final menu:Menu;

	function render():Child {
		return Dropdown.build({
			label: dropdown -> Button.build({
				action: () -> dropdown.toggle(),
				child: menu.label
			}),
			child: _ -> Html.ul()
				.style(Breeze.compose(
					Flex.display(),
					Flex.direction('column'),
					Flex.gap(3),
					Background.color('white', 0),
					Spacing.pad(3),
					Border.radius(.5),
					Effect.shadow('lg'),
					Layout.position('fixed')
				))
				.on(Click, e -> e.stopPropagation())
				.children([for (option in menu.options)
					DropdownMenuOption.build({option: option})
				])
		});
	}
}
