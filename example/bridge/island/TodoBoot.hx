package bridge.island;

import pine.*;
import pine.bridge.*;
import todo.Todo.TodoApp;

class TodoBoot extends Island {
  public function render():Child {
    return TodoApp.build({});
  }
}
