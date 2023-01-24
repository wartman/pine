package todo;

import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.ClientRoot;
import pine.state.*;
import haxe.Json;

using Reflect;

function main() {
  ClientRoot.mount(
    Browser.document.getElementById('root'),
    new TodoApp({})
  );
}

class Todo implements Record {
  public final id:Int;
  public var description:String;
  public var isCompleted:Bool;
  public var isEditing:Bool;

  public function toJson() {
    return {
      id: id,
      description: description,
      isCompleted: isCompleted,
      isEditing: isEditing
    };
  }
}

enum abstract TodoVisibility(String) from String to String {
  final All;
  final Completed;
  final Active;
}

typedef TodoProvider = Provider<TodoStore>;

class TodoStore implements Record {
  static inline final storageId = 'pine-todo-store';

  public inline static function from(context:Context) {
    return TodoProvider.from(context);
  }

  public static function load() {
    var data = js.Browser.window.localStorage.getItem(storageId);
    var store = if (data == null) {
      new TodoStore({uid: 0, todos: [], visibility: All});
    } else {
      fromJson(Json.parse(data));
    }

    Observer.track(() -> {
      js.Browser.window.localStorage.setItem(TodoStore.storageId, Json.stringify(store.toJson()));
    });

    return store;
  }

  public static function fromJson(data:Dynamic) {
    return new TodoStore({
      uid: data.field('uid'),
      todos: (data.field('todos') : Array<Dynamic>).map(Todo.new),
      visibility: data.field('visibility')
    });
  }

  var uid:Int;
  public var visibility:TodoVisibility;
  public var todos:Array<Todo>;

  public function addTodo(description:String) {
    todos.unshift(new Todo({
      id: uid++,
      description: description,
      isEditing: false,
      isCompleted: visibility == Completed
    }));
  }

  public function removeTodo(todo:Todo) {
    todos.remove(todo);
  }

  public function removeCompletedTodos() {
    todos.replace(todos.filter(t -> !t.isCompleted));
  }

  public function toJson() {
    return {
      uid: uid,
      todos: todos.map(todo -> todo.toJson()),
      visibility: visibility
    };
  }
}

class TodoApp extends AutoComponent {
  public function render(context:Context):Component {
    return new TodoProvider({
      create: TodoStore.load,
      dispose: store -> store.dispose(),
      render: store -> new Html<'div'>({
        className: 'todomvc-wrapper',
        children: [
          new Portal({
            target: js.Browser.document.head,
            child: new Scope({ 
              render: context -> {
                // note: We could use `store` from the wrapping scope,
                // but this shows that `context` is passed down even through
                // portals.
                var store = TodoStore.from(context);
                var total = store.todos.length;
                var todosLeft = total - store.todos.filter(todo -> todo.isCompleted).length;
                return new Html<'title'>({ children: 'TodoMVC | Pine | ${todosLeft} / ${total}' });
              }
            })
          }),
          new Html<'section'>({
            className: 'todoapp',
            children: [
              new Html<'header'>({
                className: 'header',
                role: 'header',
                children: [
                  new Html<'h1'>({ children: [ 'todos' ] }),
                  new TodoInput({ 
                    className: 'new-todo',
                    value: '',
                    clearOnComplete: true,
                    onCancel: () -> null,
                    onSubmit: data -> store.addTodo(data)
                  })
                ]
              }),
              new TodoContainer({
                store: store
              }),
              new TodoFooter({
                store: store
              })
            ]
          })
        ]
      })
    });
  }
}

class TodoFooter extends AutoComponent {
  final store:TodoStore;

  public function render(context:Context):Component {
    var total = store.todos.length;
    var todosCompleted = total - store.todos.filter(todo -> !todo.isCompleted).length;
    var todosLeft = total - store.todos.filter(todo -> todo.isCompleted).length;
    
    return new Html<'footer'>({
      className: 'footer',
      style: if (total == 0) 'display: none' else null,
      children: [
        new Html<'span'>({
          className: 'todo-count',
          children: new Html<'strong'>({ children: switch todosLeft {
            case 1: '${todosLeft} item left';
            default: '${todosLeft} items left';
          } })
        }),
        new Html<'ul'>({
          className: 'filters',
          children: [
            visibilityControl('#/', All, store.visibility),
            visibilityControl('#/active', Active, store.visibility),
            visibilityControl('#/completed', Completed, store.visibility)
          ]
        }),
        new Html<'button'>({
          className: 'clear-completed',
          style: if (todosCompleted == 0) 'visibility: hidden' else null,
          onclick: _ -> store.removeCompletedTodos(),
          children: 'Clear completed (${todosCompleted})'
        })
      ]
    });
  }

  inline function visibilityControl(
    url:String,
    visibility:TodoVisibility,
    actualVisibility:TodoVisibility
  ) {
    return new Html<'li'>({
      onclick: _ -> store.visibility = visibility,
      children: [
        new Html<'a'>({
          href: url,
          className: if (visibility == actualVisibility) 'selected' else null,
          children: (visibility:String)
        })
      ]
    });
  }
}


class TodoContainer extends AutoComponent {
  final store:TodoStore;

  function render(context:Context) {
    var len = store.todos.length;
    var items = store.todos.filter(todo -> switch store.visibility {
      case All: true;
      case Completed: todo.isCompleted;
      case Active: !todo.isCompleted;
    });

    return new Html<'section'>({
      className: 'main',
      ariaHidden: len == 0,
      style: if (len == 0) 'visibility: hidden' else null,
      children: [
        // @todo: toggles
        new Html<'ul'>({
          className: 'todo-list',
          children: [
            for (todo in items)
              new TodoItem({todo: todo, key: todo.id})
          ]
        })
      ]
    });
  }
}

class TodoItem extends AutoComponent {
  final todo:Todo;

  inline function getClassName() {
    return [
      if (todo.isCompleted) 'completed' else null,
      if (todo.isEditing) 'editing' else null
    ].filter(c -> c != null).join(' ');
  }

  function render(context:Context) {
    return new Html<'li'>({
      key: todo.id,
      id: 'todo-${todo.id}',
      className: getClassName(),
      children: [ 
        new Html<'div'>({
          className: 'view',
          children: [
            new Html<'input'>({
              className: 'toggle',
              type: Checkbox,
              checked: todo.isCompleted,
              onclick: _ -> todo.isCompleted = !todo.isCompleted
            }), 
            new Html<'label'>({
              ondblclick: e -> todo.isEditing = true,
              onclick: e -> {
                e.preventDefault();
                e.stopPropagation();
              },
              children: [
                todo.description,
                new Html<'button'>({
                  className: 'destroy',
                  onclick: _ -> TodoStore.from(context).removeTodo(todo)
                })
              ]
            }),
          ]
        }),
        new TodoInput({
          className: 'edit',
          value: todo.description,
          clearOnComplete: false,
          isEditing: todo.isEditing,
          onCancel: () -> todo.isEditing = false,
          // Note: Using `Action` is not required, but it can help
          // ensure changes are batched.
          onSubmit: data -> Action.run(() -> {
            todo.description = data;
            todo.isEditing = false;
          })
        })
      ]
    });
  }
}

class TodoInput extends AutoComponent {
  final className:String;
  final clearOnComplete:Bool;
  final onSubmit:(data:String) -> Void;
  final onCancel:() -> Void;
  public var isEditing:Bool = false;
  var value:String;

  function render(context:Context):Component {
    Hook.from(context).useEffect(() -> {
      if (isEditing) {
        var el:js.html.InputElement = cast context.getObject();
        el.focus();
      }
    });

    return new Html<'input'>({
      className: className,
      placeholder: 'What needs doing?',
      autofocus: true,
      value: value == null ? '' : value,
      name: className,
      oninput: e -> {
        var target:js.html.InputElement = cast e.target;
        value = target.value;
      },
      onblur: _ -> {
        onCancel();
        if (clearOnComplete) {
          value = '';
        }
      },
      onkeydown: e -> {
        var ev:js.html.KeyboardEvent = cast e;
        if (ev.key == 'Enter') {
          onSubmit(value);
          if (clearOnComplete) {
            value = '';
          }
        } else if (ev.key == 'Escape') {
          onCancel();
          if (clearOnComplete) {
            value = '';
          }
        }
      }
    });
  }
}
