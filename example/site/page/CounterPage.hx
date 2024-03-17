package site.page;

import pine.router.Page;
import site.component.core.Section;
import site.island.CounterIsland;
import site.layout.MainLayout;
import site.style.Core;

class CounterPage extends Page<'/counter/{initialCount:Int}'> {
  function render():Child {
    return MainLayout.build({
      title: 'Counter | ${params.initialCount}',
      children: Html.div()
        .style(centered)
        .children(
          Section.build({
            constrain: true,
            children: CounterIsland.build({ count: params.initialCount })
          })
        )
    });
  }
}
