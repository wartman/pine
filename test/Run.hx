import pine.*;
import impl.*;

function main() {
  var boot = new TestingBootstrap();
  var root = boot.mount(new Foo({foo: 'foo'}));
  trace(root.toString());
}

class SimpleState extends Observable<SimpleState> {
  var foo:String;

  public function new(foo) {
    super(this);
    this.foo = foo;
  }

  public function setFoo(foo) {
    this.foo = foo;
    notify();
  }

  public function getFoo() {
    return foo;
  }
}

class Foo extends ImmutableComponent {
  @prop final foo:String;
  @prop final bar:String = 'bar';

  public function render(context:Context):Component {
    return new Fragment({
      children: [
        new TextComponent({content: 'bar'}),
        new TextComponent({content: foo}),
        new TextComponent({content: bar}),
        new Provider<SimpleState>({
          create: () -> new SimpleState(foo),
          dispose: state -> state.dispose(),
          render: _ -> new Provider<String>({
            create: () -> 'provided',
            dispose: _ -> null,
            render: _ -> new FooConsumer({})
          })
        })
      ]
    });
  }
}

class FooConsumer extends ImmutableComponent {
  public function render(context:Context):Component {
    return new Consumer<{state:SimpleState, stuff:String}>({
      render: value -> switch value {
        case Some(data):
          data.state.render(state -> {
            // state.setFoo('bar');
            new TextComponent({content: state.getFoo() + ' ' + data.stuff});
          });
        case None:
          new TextComponent({content: 'none'});
      }
    });
  }
}
