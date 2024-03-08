package site.island;

import pine.bridge.Island;
import todo.Todo;

class TodoIsland extends Island {
  @:attribute final store:TodoStore;

  function render():Child {
    return TodoApp.build({ store: store });
  }
}
