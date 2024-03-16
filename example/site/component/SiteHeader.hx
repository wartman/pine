package site.component;

import pine.router.RouteVisitor;
import site.page.*;
import site.style.*;
import site.island.*;
import site.data.*;

class SiteHeader extends Component {
  function render() {
    var postMenu = new Menu({
      label: 'Posts',
      options: [
        new MenuOption({
          label: 'First Post',
          type: PageLink,
          url: PostPage.createUrl({ id: 1 })
        }),
        new MenuOption({
          label: 'Second Post',
          type: PageLink,
          url: PostPage.createUrl({ id: 2 })
        }),
        new MenuOption({
          label: 'Third Post',
          type: PageLink,
          url: PostPage.createUrl({ id: 3 })
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
        Flex.display(),
        Core.centered
      )}>
        <h2 class={Breeze.compose(
          Typography.fontSize('lg'),
          Typography.fontWeight('bold'),
          Spacing.margin('right', 'auto')
        )}>{HomePage.link({}).children("Example Site")}</h2>
        <nav>
          <ul class={Breeze.compose(
            Flex.display(),
            Flex.direction('row'),
            Flex.alignItems('center'),
            Flex.gap(3),
            Sizing.height('100%'),
          )}>
            <li>{TodoPage.link({}).children("Todos Example")}</li>
            <li><DropdownMenu menu=postMenu /></li>
            <li>{CounterPage.link({ initialCount: 2 }).children("Counter Example (starts at 2)")}</li>
            <li>{CounterPage.link({ initialCount: 10 }).children("Counter Example (starts at 10)")}</li>
          </ul>
        </nav>
      </header>
    );
  }
}
