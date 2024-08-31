package site.island;

import site.component.core.Section;
import pine.bridge.Island;
import site.component.example.*;

class ExamplesIsland extends Island {
	function render():Child {
		return Html.div()
			.children(
				Section.build({
					children: [
						CarouselExample.build({}),
						CollapseExample.build({}),
						AnimationExample.build({})
					]
				})
			);
	}
}
