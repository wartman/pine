package site.page;

import site.layout.MainLayout;
import pine.router.Page;
import site.island.CounterIsland;

class CounterPage extends Page<'/counter/{initialCount:Int}'> {
  function render():Child {
    return MainLayout.build({
      title: 'Counter | ${params.initialCount}',
      children: CounterIsland.build({ count: params.initialCount })
    });
  }
}
