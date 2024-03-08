package site.component;

import site.page.*;

class SiteHeader extends Component {
  function render() {
    return view(
      <header class={Breeze.compose(
        Flex.display(),
        Spacing.margin('x', 'auto'),
        Spacing.pad('y', 3),
        Breakpoint.viewport('900px',
          Sizing.width('max', '900px')
        ),
      )}>
        <h2 class={Breeze.compose(
          Typography.fontSize('lg'),
          Typography.fontWeight('bold')
        )}>{HomePage.link({}).children("Example Site")}</h2>
        <nav>
          <ul>
            <li>{TodoPage.link({}).children("Todos Example")}</li>
            <li>{CounterPage.link({ initialCount: 2 }).children("Counter Example (starts at 2)")}</li>
            <li>{CounterPage.link({ initialCount: 10 }).children("Counter Example (starts at 10)")}</li>
          </ul>
        </nav>
      </header>
    );
  }
}
