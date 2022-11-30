package todo;

import pine.*;
import pine.state.*;
import haxe.Json;

function main() {
  
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

// typedef TodoProvider = Provider<TodoStore>;

class TodoStore implements Record {
  static inline final storageId = 'pine-todo-store';

  // public inline static function from(context:Context) {
  //   return TodoProvider.from(context);
  // }

  public static function load() {
    #if nodejs
    return new TodoStore({uid: 0, todos: [], visibility: All});
    #else
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
    return null;
  }
}

class TodoFooter extends AutoComponent {
  @prop final store:TodoStore;

  function render(context:Context) {
    return null;
  }
}
