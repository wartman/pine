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

class Todo implements Record {
  public final id:Int;
  public var description:String;
  public var isCompleted:Bool;
  public var isEditing:Bool;
  
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

class TodoStore implements Record {
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

  var uid:Int;
  public var visibility:TodoVisibility;
  public var todos:Array<Todo>;
  
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
      create: TodoStore.load,
      dispose: _ -> null,
      build: store -> new Html<'div'>({
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
  final store:TodoStore;

  public function build():Component {
    var total = compute(() -> store.todos().length);
    var todosCompleted = compute(() -> total() - store.todos().filter(todo -> !todo.isCompleted()).length);
    var todosLeft = compute(() -> total() - store.todos().filter(todo -> todo.isCompleted()).length);
    
    return new Html<'footer'>({
      className: 'footer',
      style: if (total == 0) 'display: none' else null,
      children: [
        new Html<'span'>({
          className: 'todo-count',
          children: new Html<'strong'>({ 
            children: [
              new Text(compute(() -> switch todosLeft() {
                case 1: '1 item left';
                default: '${todosLeft()} items left';
              }))
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
          style: compute(() -> if (todosCompleted() == 0) 'visibility: hidden' else null),
          onclick: _ -> store.removeCompletedTodos(),
          children: [ 
            'Clear completed (', 
            new Text(compute(() -> Std.string(todosCompleted()))), 
            ')' 
          ]
        })
      ]
    });
  }
}

class VisibilityControl extends AutoComponent {
  final store:TodoStore;
  final visibility:TodoVisibility;
  final url:String;
  
  function build() {
    return new Html<'li'>({
      onclick: _ -> store.visibility.set(visibility),
      children: [
        new Html<'a'>({
          href: url,
          className: compute(() -> if (visibility == store.visibility()) 'selected' else null),
          children: (visibility:String)
        })
      ]
    });
  }
}

class TodoContainer extends AutoComponent {
  final store:TodoStore;

  function build() {
    final len = compute(() -> store.todos().length);
    final items = compute(() -> {
      var visibility = store.visibility();
      store.todos().filter(todo -> switch visibility {
        case All: true;
        case Completed: todo.isCompleted();
        case Active: !todo.isCompleted();
      });
    });

    return new Html<'section'>({
      className: 'main',
      ariaHidden: compute(() -> len() == 0),
      style: compute(() -> if (len() == 0) 'visibility: hidden' else null),
      children: [
        // @todo: toggles
        new Html<'ul'>({
          className: 'todo-list',
          children: new For(items, todo -> new TodoItem({todo: todo}))
          // children: [
          //   for (todo in items)
          //     new TodoItem({todo: todo, key: todo.id})
          // ]
        })
      ]
    });
  }
}

class TodoItem extends AutoComponent {
  final todo:Todo;

  function build() {
    var className = compute(() -> [
      if (todo.isCompleted()) 'completed' else null,
      if (todo.isEditing()) 'editing' else null
    ].filter(c -> c != null).join(' '));

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
              onclick: _ -> todo.isCompleted.update(status -> !status)
            }), 
            new Html<'label'>({
              ondblclick: e -> todo.isEditing.set(true),
              onclick: e -> {
                e.preventDefault();
                e.stopPropagation();
              },
              children: [
                todo.description,
                new Html<'button'>({
                  className: 'destroy',
                  onclick: _ -> TodoStore.from(this).removeTodo(todo)
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
  final className:String;
  final clearOnComplete:Bool;
  final onSubmit:(data:String) -> Void;
  final onCancel:() -> Void;
  var isEditing:Bool = false;
  var value:String;

  function build():Component {
    effect(() -> {
      if (isEditing()) {
        var el:js.html.InputElement = getObject();
        // Focus doesn't work for some reason :\
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
        value.set(target.value);
      },
      onblur: _ -> {
        onCancel();
        if (clearOnComplete) {
          value.set('');
        }
      },
      onkeydown: e -> {
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


