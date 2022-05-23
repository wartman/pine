package todo;

import haxe.Json;
#if (js && !nodejs)
  import pine.html.dom.DomBootstrap;
#else
  import pine.html.server.ServerBootstrap;
#end
import pine.*;
import pine.track.*;
import pine.html.Html;

using Reflect;

function main() {
  var boot = #if (js && !nodejs) 
    new DomBootstrap();
  #else 
    new ServerBootstrap();
  #end
  boot.mount(new TodoApp({}));
}

class Todo implements Record {
  @prop public final id:Int;
  @observe public var description:String;
  @observe public var isCompleted:Bool;
  @observe public var isEditing:Bool;

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
  static inline final BLOK_TODO_STORE = 'blok-todo-store';

  public inline static function from(context:Context) {
    return TodoProvider.from(context);
  }

  public static function load() {
    #if nodejs
      return new TodoStore({uid: 0, todos: [], visibility: All});
    #else
      var data = js.Browser.window.localStorage.getItem(BLOK_TODO_STORE);
      var store = if (data == null) {
        new TodoStore({uid: 0, todos: [], visibility: All});
      } else {
        fromJson(Json.parse(data));
      }
      store.observe().bindNext(_ -> save(store));
      return store;
    #end
  }

  public static function save(store:TodoStore) {
    #if !nodejs
    js.Browser.window.localStorage.setItem(BLOK_TODO_STORE, Json.stringify(store.toJson()));
    #end
  }

  public static function fromJson(data:Dynamic) {
    return new TodoStore({
      uid: data.field('uid'),
      todos: (data.field('todos') : Array<Dynamic>).map(Todo.new),
      visibility: data.field('visibility')
    });
  }

  @observe var uid:Int;
  @observe public var visibility:TodoVisibility;
  @observe public var todos:Array<Todo>;

  public function addTodo(description:String) {
    todos.push(new Todo({
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
    todos.mutate(t -> !t.isCompleted);
  }

  public function toJson() {
    return {
      uid: uid,
      todos: todos.read().map(todo -> todo.toJson()),
      visibility: visibility
    };
  }
}

class TodoApp extends ImmutableComponent {
  public function render(context:Context):Component {
    return new TodoProvider({
      create: TodoStore.load,
      dispose: store -> store.dispose(),
      render: store -> Html.div({ className: 'todomvc-wrapper' },
        Html.section({ className: 'todoapp' },
          Html.header({ className: 'header', role: 'header' },
            Html.h1({}, 'todos'),
            new TodoInput({ 
              className: 'new-todo',
              value: '',
              clearOnComplete: true,
              onCancel: () -> null,
              onSubmit: data -> store.addTodo(data)
            })
          ),
          new TodoContainer({
            total: store.todos.map(todos -> todos.length),
            todos: store.select(data -> {
              visibility: data.visibility,
              todos: data.todos.toArray()
            }).map(data -> switch data.visibility {
              case All: data.todos;
              case Completed: data.todos.filter(todo -> todo.isCompleted);
              case Active: data.todos.filter(todo -> !todo.isCompleted);
            }).map(todos -> {
              todos.reverse();
              todos;
            })
          }),
          new TodoFooter({
            store: store,
            visibility: store.select(data -> data.visibility),
            totalTodos: store.todos.map(todos -> todos.length),
            completedTodos: store.todos.where(todo -> todo.isCompleted).map(todos -> todos.length)
          })
        )
      )
    });
  }
}

class TodoFooter extends TrackedComponent {
  @prop final store:TodoStore;
  @observe final visibility:TodoVisibility;
  @observe final totalTodos:Int;
  @observe final completedTodos:Int;

  public function render(context:Context):Component {
    var total = totalTodos.read();
    var todosLeft = total - completedTodos.read();
    return Html.footer({
      className: 'footer',
      style: if (total == 0) 'display: none' else null
    },
      Html.span({ className: 'todo-count' },
        Html.strong({},
          switch todosLeft {
            case 1: '${todosLeft} item left';
            default: '${todosLeft} items left';
          }
        )
      ),
      Html.ul({ className: 'filters' },
        visibilityControl('#/', All, visibility.read()),
        visibilityControl('#/active', Active, visibility.read()),
        visibilityControl('#/completed', Completed, visibility.read())
      ),
      Html.button(
        {
          className: 'clear-completed',
          style: if (completedTodos.read() == 0) 'visibility: hidden' else null,
          onclick: _ -> store.removeCompletedTodos()
        },
        'Clear completed (${completedTodos.read()})'
      )
    );
  }

  inline function visibilityControl(
    url:String,
    visibility:TodoVisibility,
    actualVisibility:TodoVisibility
  ) {
    return Html.li(
      {
        onclick: _ -> store.visibility = visibility
      },
      Html.a(
        {
          href: url,
          className: if (visibility == actualVisibility) 'selected' else null
        },
        (visibility:String)
      )
    );
  }
}

class TodoContainer extends TrackedComponent {
  @observe final total:Int;
  @observe final todos:Array<Todo>;

  function render(context:Context) {
    var len = total.read();

    return Html.section({
      className: 'main',
      ariaHidden: len == 0,
      style: if (len == 0) 'visibility: hidden' else null
    }, // @todo: toggles
      Html.ul({className: 'todo-list'}, ...[
        for (todo in todos.read())
          new TodoItem({todo: todo, key: todo.id})
      ])
    );
  }
}

class TodoItem extends TrackedComponent {
  @observe final todo:Todo;

  inline function getClassName() {
    return [
      if (todo.isCompleted) 'completed' else null,
      if (todo.isEditing) 'editing' else null
    ].filter(c -> c != null).join(' ');
  }

  function render(context:Context) {
    var todos = TodoStore.from(context);
    return Html.li({
      key: todo.id,
      id: 'todo-${todo.id}',
      className: getClassName()
    },
      Html.div({className: 'view'}, 
        Html.input({
          className: 'toggle',
          type: Checkbox,
          checked: todo.isCompleted,
          onclick: _ -> todo.isCompleted = !todo.isCompleted
        }), 
        Html.label({
            ondblclick: _ -> todo.isEditing = true
          }, 
          todo.description
        ), 
        Html.button({
          className: 'destroy',
          onclick: _ -> todos.removeTodo(todo)
        })
      ),
      new TodoInput({
        className: 'edit',
        value: todo.description,
        clearOnComplete: false,
        isEditing: todo.isEditing,
        onCancel: () -> todo.isEditing = false,
        onSubmit: data -> {
          todo.description = data;
          todo.isEditing = false;
        }
      })
    );
  }
}

class TodoInput extends TrackedComponent {
  @prop final className:String;
  @prop final clearOnComplete:Bool;
  @prop final onSubmit:(data:String) -> Void;
  @prop final onCancel:() -> Void;
  @prop final isEditing:Bool = false;
  @observe var value:String;

  function render(context:Context):Component {
    Effect.from(context).add(_ -> {
      if (isEditing) { 
        var el:js.html.InputElement = context.getObject();
        el.focus();
      }
    });

    return Html.input({
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
