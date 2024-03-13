package site.page;

import pine.router.Page;
import site.layout.MainLayout;
import todo.Todo;

class TodoPage extends Page<'/todo'> {
  function render():Child {
    var store = new TodoStore({
      uid: 1,
      visibility: All,
      todos: [
        new Todo({
          id: 0,
          description: 'Hello world',
          isEditing: false,
          isCompleted: false
        })
      ]
    });

    return view(<MainLayout title="Todos">
      <TodoApp store=store />
    </MainLayout>);
  }
}
