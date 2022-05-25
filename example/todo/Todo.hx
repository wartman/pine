package todo;

import haxe.Json;
#if (js && !nodejs)
  import pine.html.dom.DomBootstrap;
#else
  import pine.html.server.ServerBootstrap;
#end
import pine.*;
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
  @track public var description:String;
  @track public var isCompleted:Bool;
  @track public var isEditing:Bool;

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

      TrackingTools.track(() -> {
        js.Browser.window.localStorage.setItem(BLOK_TODO_STORE, Json.stringify(store.toJson()));
      });

      return store;
    #end
  }

  public static function fromJson(data:Dynamic) {
    return new TodoStore({
      uid: data.field('uid'),
      todos: (data.field('todos') : Array<Dynamic>).map(Todo.new),
      visibility: data.field('visibility')
    });
  }

  @track var uid:Int;
  @track public var visibility:TodoVisibility;
  @track public var todos:Array<Todo>;

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
    todos.set(todos.filter(t -> !t.isCompleted));
  }

  public function toJson() {
    return {
      uid: uid,
      todos: todos.map(todo -> todo.toJson()),
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
            store: store
          }),
          new TodoFooter({
            store: store
          })
        )
      )
    });
  }
}

class TodoFooter extends ObserverComponent {
  @prop final store:TodoStore;

  public function render(context:Context):Component {
    var total = store.todos.length;
    var todosCompleted = total - store.todos.filter(todo -> !todo.isCompleted).length;
    var todosLeft = total - store.todos.filter(todo -> todo.isCompleted).length;
    
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
        visibilityControl('#/', All, store.visibility),
        visibilityControl('#/active', Active, store.visibility),
        visibilityControl('#/completed', Completed, store.visibility)
      ),
      Html.button(
        {
          className: 'clear-completed',
          style: if (todosCompleted == 0) 'visibility: hidden' else null,
          onclick: _ -> store.removeCompletedTodos()
        },
        'Clear completed (${todosCompleted})'
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

class TodoContainer extends ObserverComponent {
  @prop final store:TodoStore;

  function render(context:Context) {
    var len = store.todos.length;
    var items = store.todos.filter(todo -> switch store.visibility {
      case All: true;
      case Completed: todo.isCompleted;
      case Active: !todo.isCompleted;
    });
    items.reverse();

    return Html.section({
      className: 'main',
      ariaHidden: len == 0,
      style: if (len == 0) 'visibility: hidden' else null
    }, // @todo: toggles
      Html.ul({className: 'todo-list'}, ...[
        for (todo in items)
          new TodoItem({todo: todo, key: todo.id})
      ])
    );
  }
}

class TodoItem extends ObserverComponent {
  @prop final todo:Todo;

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

class TodoInput extends ObserverComponent {
  @prop final className:String;
  @prop final clearOnComplete:Bool;
  @prop final onSubmit:(data:String) -> Void;
  @prop final onCancel:() -> Void;
  @prop final isEditing:Bool = false;
  @track var value:String;

  function render(context:Context):Component {
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
