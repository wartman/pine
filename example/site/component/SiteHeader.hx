package site.component;

import pine.router.*;
import site.style.*;
import site.island.*;
import site.data.*;

// Just as an example: the `Route` class has `createRoute` and
// `link` static methods available for type-safe navigation. To use
// them, just create a typedef like the following:
typedef PostRoute = Route<"/post/{id:Int}">;

class SiteHeader extends Component {
	function render() {
		var postMenu = new Menu({
			label: 'Posts',
			options: [
				new MenuOption({
					label: 'First Post',
					type: PageLink,
					url: PostRoute.createUrl({id: 1})
				}),
				new MenuOption({
					label: 'Second Post',
					type: PageLink,
					url: PostRoute.createUrl({id: 2})
				}),
				new MenuOption({
					label: 'Third Post',
					type: PageLink,
					url: PostRoute.createUrl({id: 3})
				})
			]
		});

		// Note: this is a hack to ensure our post routes are visited, as
		// the server will not activate the menu.
		//
		// This is probably a good argument *not* to build site-nav
		// menus this way, but for this example's sake we'll do it.
		var visitor = getContext(RouteVisitor);
		if (visitor != null) for (option in postMenu.options) {
			visitor.enqueue(option.url);
		}

		return view(
			<header class={Breeze.compose(
        Background.color('black', 0),
        Typography.textColor('white', 0)
      )}>
        <div class={Breeze.compose(
          Sizing.height('100%'),
          Flex.display(),
          Spacing.pad('y', 3),
          Core.centered
        )}>
          <h2 class={Breeze.compose(
            Typography.fontSize('lg'),
            Typography.fontWeight('bold'),
            Flex.display(),
            Flex.alignItems('center'),
            Sizing.height('100%'),
            Spacing.margin('right', 'auto')
          )}>{Link.to("/").children("Example Site")}</h2>
          <nav>
            <ul class={Breeze.compose(
              Flex.display(),
              Flex.direction('row'),
              Flex.alignItems('center'),
              Flex.gap(3),
              Sizing.height('100%'),
            )}>
              <li>{Link.to("/todos").children("Todos Example")}</li>
              <li><DropdownMenu menu=postMenu /></li>
              <li>{Link.to("/counter/2").children("Counter Example (starts at 2)")}</li>
              <li>{Link.to("/counter/10").children("Counter Example (starts at 10)")}</li>
              <li>{Link.to("/component-examples").children("More Examples")}</li>
            </ul>
          </nav>
        </div>
      </header>
		);
	}
}
