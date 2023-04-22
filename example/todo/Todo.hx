package todo;

import haxe.Json;
import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.HtmlAttributes.InputType;
import pine.html.client.Client;
import pine.signal.*;

using Reflect;

function main() {
  mount(
    Browser.document.getElementById('root'),
    () -> new TodoApp({})
  );
}

class Todo extends Record {
  @:constant public final id:Int;
  @:signal public final description:String;
  @:signal public final isCompleted:Bool;
  @:signal public final isEditing:Bool;
  
  public function toJson() {
    return {
      id: id,
      description: description(),
      isCompleted: isCompleted(),
      isEditing: isEditing()
    };
  }
}

enum abstract TodoVisibility(String) from String to String {
  final All;
  final Completed;
  final Active;
}

typedef TodoProvider = Provider<TodoStore>;

class TodoStore extends Record {
  static inline final storageId = 'pine-todo-store';

  public inline static function from(context:Component) {
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
      uid: new Signal(data.field('uid')),
      todos: new Signal((data.field('todos'):Array<Dynamic>).map(data -> new Todo({
        id: data.id,
        description: new Signal(data.description),
        isCompleted: new Signal(data.isCompleted),
        isEditing: new Signal(data.isEditing),
      }))),
      visibility: new Signal(data.field('visibility'))
    });
  }

  @:signal final uid:Int;
  @:signal public final visibility:TodoVisibility;
  @:signal public final todos:Array<Todo>;
  @:computed public final total:Int = todos().length;
  @:computed public final completed:Int = total() - todos().filter(todo -> !todo.isCompleted()).length;
  @:computed public final remaining:Int = total() - todos().filter(todo -> todo.isCompleted()).length;
  
  public function addTodo(description:String) {
    uid.update(id -> id + 1);
    todos.update(todos -> [ new Todo({
      id: uid.peek(),
      description: description,
      isEditing: false,
      isCompleted: visibility.peek() == Completed
    }) ].concat(todos));
  }

  public function removeTodo(todo:Todo) {
    todos.update(todos -> todos.filter(t -> t != todo));
  }

  public function removeCompletedTodos() {
    todos.update(todos -> todos.filter(t -> !t.isCompleted.peek()));
  }

  public function toJson() {
    return {
      uid: uid(),
      todos: todos().map(todo -> todo.toJson()),
      visibility: visibility()
    };
  }
}

class TodoApp extends AutoComponent {
  function build() {
    return new TodoProvider({
      value: TodoStore.load(),
      child: store -> new Html<'div'>({
        className: 'todomvc-wrapper',
        children: [
          // @todo: portal
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
  @:constant final store:TodoStore;

  public function build():Component {
    return new Html<'footer'>({
      className: 'footer',
      style: store.total.map(total -> if (total == 0) 'display: none' else null),
      children: [
        new Html<'span'>({
          className: 'todo-count',
          children: new Html<'strong'>({ 
            children: [
              store.remaining.map(remaining -> switch remaining {
                case 1: '1 item left';
                default: '${remaining} items left';
              })
            ]
          })
        }),
        new Html<'ul'>({
          className: 'filters',
          children: [
            new VisibilityControl({ url:'#/', visibility: All, store: store }),
            new VisibilityControl({ url: '#/active', visibility: Active, store: store }),
            new VisibilityControl({ url: '#/completed', visibility: Completed, store: store })
          ]
        }),
        new Html<'button'>({
          className: 'clear-completed',
          style: store.completed.map(completed -> if (completed == 0) 'visibility: hidden' else null),
          onClick: _ -> store.removeCompletedTodos(),
          children: [ 
            'Clear completed (', 
            store.completed.map(Std.string),
            ')' 
          ]
        })
      ]
    });
  }
}

class VisibilityControl extends AutoComponent {
  @:constant final store:TodoStore;
  @:constant final visibility:TodoVisibility;
  @:constant final url:String;
  
  function build() {
    return new Html<'li'>({
      onClick: _ -> store.visibility.set(visibility),
      children: [
        new Html<'a'>({
          href: url,
          className: new Computation(() -> if (visibility == store.visibility()) 'selected' else null),
          children: (visibility:String)
        })
      ]
    });
  }
}

class TodoContainer extends AutoComponent {
  @:constant final store:TodoStore;

  function build() {
    final len = store.todos.map(todos -> todos.length);
    final items = new Computation(() -> {
      var visibility = store.visibility();
      store.todos().filter(todo -> switch visibility {
        case All: true;
        case Completed: todo.isCompleted();
        case Active: !todo.isCompleted();
      });
    });

    return new Html<'section'>({
      className: 'main',
      ariaHidden: len.map(len -> len == 0),
      // Functions are cast into Computations for ReadonlySignal
      // attributes.
      style: () -> if (len() == 0) 'visibility: hidden' else null,
      children: [
        // @todo: toggles
        new Html<'ul'>({
          className: 'todo-list',
          children: new Each(items, todo -> new TodoItem({todo: todo}))
        })
      ]
    });
  }
}

class TodoItem extends AutoComponent {
  @:constant final todo:Todo;
  @:computed final className:String = [
    if (todo.isCompleted()) 'completed' else null,
    if (todo.isEditing()) 'editing' else null
  ].filter(c -> c != null).join(' ');

  function build() {
    return new Html<'li'>({
      id: 'todo-${todo.id}',
      className: className,
      children: [ 
        new Html<'div'>({
          className: 'view',
          children: [
            new Html<'input'>({
              className: 'toggle',
              type: InputType.Checkbox,
              checked: todo.isCompleted,
              onClick: _ -> todo.isCompleted.update(status -> !status)
            }), 
            new Html<'label'>({
              onDblClick: e -> todo.isEditing.set(true),
              onClick: e -> {
                e.preventDefault();
                e.stopPropagation();
              },
              children: [
                todo.description,
                new Html<'button'>({
                  className: 'destroy',
                  onClick: _ -> TodoStore.from(this).removeTodo(todo)
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
          onCancel: () -> todo.isEditing.set(false),
          // Note: Using `Action` is not required, but it can help
          // ensure changes are batched.
          onSubmit: data -> Action.run(() -> {
            todo.description.set(data);
            todo.isEditing.set(false);
          })
        })
      ]
    });
  }
}

class TodoInput extends AutoComponent {
  @:constant final className:String;
  @:constant final clearOnComplete:Bool;
  @:constant final onSubmit:(data:String) -> Void;
  @:constant final onCancel:() -> Void;
  @:signal final isEditing:Bool = false;
  @:signal final value:String;

  function build():Component {
    addEffect(() -> {
      if (isEditing()) {
        var el:js.html.InputElement = getObject();
        el.focus();
      }
      null;
    });

    return new Html<'input'>({
      className: className,
      placeholder: 'What needs doing?',
      autofocus: true,
      value: value == null ? '' : value,
      name: className,
      onInput: e -> {
        var target:js.html.InputElement = cast e.target;
        value.set(target.value);
      },
      onBlur: _ -> {
        onCancel();
        if (clearOnComplete) {
          value.set('');
        }
      },
      onKeyDown: e -> {
        var ev:js.html.KeyboardEvent = cast e;
        if (ev.key == 'Enter') {
          onSubmit(value.peek());
          if (clearOnComplete) {
            value.set('');
          }
        } else if (ev.key == 'Escape') {
          onCancel();
          if (clearOnComplete) {
            value.set('');
          }
        }
      }
    });
  }
}


