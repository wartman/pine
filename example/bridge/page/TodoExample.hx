package bridge.page;

import bridge.layout.MainLayout;
import bridge.island.*;
import pine.*;
import pine.bridge.Page;

class TodoExample extends Page<'/todo'> {
  public function render():Child {
    return MainLayout.build({
      title: 'Todos',
      children: TodoBoot.build({})
    });
  }
}
