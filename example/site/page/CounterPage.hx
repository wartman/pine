package site.page;

import pine.bridge.ServerComponent;
import site.component.core.Section;
import site.island.CounterIsland;
import site.layout.MainLayout;
import site.style.Core;

class CounterPage extends ServerComponent {
  @:attribute final initialCount:Int;

  function render():Task<Child> {
    return MainLayout.build({
      title: 'Counter | ${initialCount}',
      children: Html.div()
        .style(centered)
        .children(
          Section.build({
            constrain: true,
            children: CounterIsland.build({ count: initialCount })
          })
        )
    }).as(Child);
  }
}
