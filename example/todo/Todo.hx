package todo;

import Breeze;
import haxe.Json;
import js.Browser;
import js.html.InputElement;
import pine.*;
import pine.html.*;
import pine.html.client.ClientRoot;
import pine.signal.*;

using ex.BreezePlugin;

function todoRoot() {
  mount(Browser.document.getElementById('todo-root'), () -> TodoApp.build({}));
}

class Todo extends Model {
  @:constant public final id:Int;
  @:signal public final description:String;
  @:signal public final priority:Int = 0;
  @:signal public final isCompleted:Bool;
  @:signal public final isEditing:Bool;
}

enum abstract TodoVisibility(String) from String to String {
  final All;
  final Completed;
  final Active;
}

class TodoStore extends Model {
  static inline final storageId = 'pine-todo-store';

  public static function load():TodoStore {
    var data = js.Browser.window.localStorage.getItem(storageId);
    var context = if (data == null) {
      new TodoStore({uid: 0, todos: [], visibility: All});
    } else {
      fromJson(Json.parse(data));
    }

    Observer.track(() -> {
      js.Browser.window.localStorage.setItem(TodoStore.storageId, Json.stringify(context.toJson()));
    });

    return context;
  }

  @:signal final uid:Int;
  @:signal public final visibility:TodoVisibility;
  @:signal public final todos:Array<Todo>;
  @:computed public final total:Int = todos().length;
  @:computed public final completed:Int = total() - todos().filter(todo -> !todo.isCompleted()).length;
  @:computed public final remaining:Int = total() - todos().filter(todo -> todo.isCompleted()).length;
  @:computed public final visibleTodos:Array<Todo> = switch visibility() {
    case All: todos();
    case Completed: todos().filter(todo -> todo.isCompleted());
    case Active: todos().filter(todo -> !todo.isCompleted());
  }
  
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
    todo.dispose();
    todos.update(todos -> todos.filter(t -> t != todo));
  }

  public function removeCompletedTodos() {
    todos.update(todos -> todos.filter(todo -> {
      if (todo.isCompleted()) {
        todo.dispose();
        return false;
      }
      return true;
    }));
  }
}

class TodoApp extends Component {
  function render():Child {
    var store = TodoStore.load();
    return Html.template(<Provider value=store>
      <main class={Breeze.compose(
        Flex.display(),
        Flex.justify('center'),
        Spacing.pad(10),
      )}>
        <div class={Breeze.compose(
          Sizing.width('full'),
          Border.radius(2),
          Border.width(.5),
          Breakpoint.viewport('700px', Sizing.width('700px'))
        )}>
          <TodoHeader />
          <TodoList />
          <TodoFooter />
        </div>
      </main>
    </Provider>);
  }
}

class TodoList extends Component {
  function render():Child {
    final store = get(TodoStore);
    return Html.template(<ul class={Breeze.compose(
      Flex.display(),
      Flex.gap(3),
      Flex.direction('column'),
      Spacing.pad(3)
    )} ref={el -> trace(el)}>
      <For each={store.visibleTodos}>
        {todo -> <TodoItem todo=todo />}
      </For>
    </ul>);
  }
}

class TodoFooter extends Component {
  function render():Child {
    var store = get(TodoStore);
    return Html.footer()
      .style(Breeze.compose(
        Background.color('black', 0),
        Typography.textColor('white', 0),
        Spacing.pad(3)
      ))
      .attr(Style, store.total.map(total -> if (total == 0) 'display: none' else null))
      .children(
        Html.span().children(
          Html.strong().children(store.remaining.map(remaining -> switch remaining {
            case 1: '1 item left';
            default: '${remaining} items left';
          }))
        )
      );
  }
}

class TodoHeader extends Component {
  function render():Child {
    var store = get(TodoStore);
    var placeholder = new Signal('');

    return Html.header()
      .style(Breeze.compose(
        Spacing.pad('x', 3)
      ))
      .attr('role', 'header')
      .children([
        Html.build('div')
          .style(Breeze.compose(
            Flex.display(),
            Flex.gap(3),
            Flex.alignItems('center'),
            Spacing.pad('y', 3),
            Border.width('bottom', .5)
          ))
          .children([
            Html.build('h1').style(Breeze.compose(
              Typography.fontSize('lg'),
              Typography.fontWeight('bold'),
              Spacing.margin('right', 'auto')
            )).children('Todos'),
            TodoInput.build({
              styles: Sizing.width('70%'),
              name: 'create',
              value: placeholder,
              onSubmit: data -> {
                store.addTodo(data);
                placeholder.set('');
              },
              onCancel: () -> {
                placeholder.set('');
              }
            })
          ]),

        Html.build('ul')
          .style(Breeze.compose(
            Flex.display(),
            Flex.gap(3),
            Spacing.pad('y', 3),
            Border.width('bottom', .5)
          ))
          .children([
            VisibilityControl.build({ visibility: All }),
            VisibilityControl.build({ visibility: Active }),
            VisibilityControl.build({ visibility: Completed }),
          ])
      ]);
  }
}

class TodoItem extends Component {
  @:attribute final todo:Todo;
  
  function render():Child {
    var store = get(TodoStore);

    return Html.template(<li class={new Computation(() -> Breeze.compose(
      Flex.display(),
      Flex.gap(3),
      Flex.alignItems('center'),
      Spacing.pad('y', 3),
      Border.width('bottom', .5),
      Border.color('gray', 300),
      Select.child('last', Border.style('bottom', 'none')),
      if (todo.isCompleted() && !todo.isEditing()) Typography.textColor('gray', 500) else null
    ))} id='todo-${todo.id}' onDblClick={_ -> todo.isEditing.set(true)}>
      <Show 
        condition={todo.isEditing}
        fallback={() -> <>
          <input 
            class="toggle" 
            checked={todo.isCompleted}
            type={pine.html.HtmlAttributes.InputType.Checkbox}
            onClick={_ -> todo.isCompleted.update(status -> !status)}
          />
          <div class={Spacing.margin('right', 'auto')}>
            {todo.description}
          </div>
          <Button action={() -> todo.isEditing.set(true)}>'Edit'</Button>
          <Button action={() -> store.removeTodo(todo)}>'Remove'</Button>
        </>}
        children={() -> <>
          <TodoInput
            styles={Sizing.width('full')}
            name='edit'
            value={todo.description}
            isEditing={todo.isEditing}
            onCancel={() -> todo.isEditing.set(false)}
            onSubmit={data -> {
              todo.description.set(data);
              todo.isEditing.set(false);
            }}
          />
          <Button action={() -> todo.isEditing.set(false)}>'Cancel'</Button>
        </>}
      />
    </li>);
  }
}

class TodoInput extends Component {
  @:attribute final styles:Null<ClassName> = null;
  @:attribute final name:String;
  @:attribute final onSubmit:(data:String) -> Void;
  @:attribute final onCancel:() -> Void;
  @:observable final isEditing:Bool = false;
  @:observable final value:String;

  function render():Child {
    var el:Signal<Null<InputElement>> = new Signal(null);
    var currentValue = new Signal(value.peek());

    Observer.track(() -> {
      var el = el();
      if (isEditing()) {
        trace(el);
        el?.focus();
      }
    });

    return Html.input()
      .style(Breeze.compose(
        styles,
        Spacing.pad('x', 3),
        Spacing.pad('y', 1),
        Border.radius(2),
        Border.color('black', 0),
        Border.width(.5)
      ))
      .ref(ref -> el.set(ref))
      .attr('name', name)
      .attr('value', value)
      .attr('placeholder', 'What needs doing?')
      .on(Input, e -> {
        var target:js.html.InputElement = cast e.target;
        currentValue.set(target.value);
      })
      .on(Blur, _ -> onCancel())
      .on(KeyDown, e -> {
        var ev:js.html.KeyboardEvent = cast e;
        if (ev.key == 'Enter') {
          onSubmit(currentValue.peek());
        } else if (ev.key == 'Escape') {
          onCancel();
        }
      });
  }
}

class VisibilityControl extends Component {
  @:attribute final visibility:TodoVisibility;

  function render():Child {
    var store = get(TodoStore);
    return Html.li().children(
      Button.build({
        action: () -> store.visibility.set(visibility),
        selected: store.visibility.map(currentVisibility -> visibility == currentVisibility),
        child: Text.ofString(visibility)
      })
    );
  }
}

class Button extends Component {
  @:observable final selected:Bool = false;
  @:attribute final action:()->Void;
  @:children @:attribute var child:Child;

  function render():Child {
    return Html.button()
      .style(new Computation<ClassName>(() -> [
        Spacing.pad('x', 3),
        Spacing.pad('y', 1),
        Border.radius(2),
        Border.width(.5),
        Border.color('black', 0),
        if (selected()) Breeze.compose(
          Background.color('black', 0),
          Typography.textColor('white', 0)
        ) else Breeze.compose(
          Background.color('white', 0),
          Typography.textColor('black', 0),
          Modifier.hover(
            Background.color('gray', 200)
          )
        )
      ]))
      .on(Click, _ -> action())
      .children(child);
  }
}
