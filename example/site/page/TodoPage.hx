package site.page;

import pine.router.Page;
import site.layout.MainLayout;
import site.component.core.*;
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
      <Section constrain>
        <p>
          "Note: the TodoMVC implementation here "<i>"does"</i>" actually have "
          "the ability to persist itself in local storage, but we don't "
          "use it yet as it would break the Island hydration step."
        </p>
        <p>"Ideally we'll have a solution soon."</p>
      </Section>
      <TodoApp store=store />
    </MainLayout>);
  }
}
