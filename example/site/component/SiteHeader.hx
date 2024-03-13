package site.component;

import site.page.*;
import site.style.*;

class SiteHeader extends Component {
  function render() {
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
            <li>{PostPage.link({ id: 1 }).children("First Post")}</li>
            <li>{PostPage.link({ id: 2 }).children("Second Post")}</li>
            <li>{PostPage.link({ id: 3 }).children("Third Post")}</li>
            <li>{CounterPage.link({ initialCount: 2 }).children("Counter Example (starts at 2)")}</li>
            <li>{CounterPage.link({ initialCount: 10 }).children("Counter Example (starts at 10)")}</li>
          </ul>
        </nav>
      </header>
    );
  }
}
