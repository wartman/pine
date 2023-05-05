package async;

import haxe.Timer;
import js.Browser;
import pine.*;
import pine.html.*;
import pine.html.client.Client;

using Kit;

function suspense() {
  mount(
    Browser.document.getElementById('suspense-root'),
    () -> new SuspenseExample({})
  );
}

class SuspenseExample extends AutoComponent {
  function build() {
    return new Fragment([
      new Html<'h3'>({ children: 'With Fallback' }),
      new Suspense({
        onComplete: () -> trace('All resources loaded with fallback.'),
        fallback: () -> 'loading...',
        child: new Fragment([
          new Target({ message: 'First', delay: 1000 }),
          new Target({ message: 'Second', delay: 1500 }),
          new Target({ message: 'Third', delay: 2000 }),
        ])
      }),
      new Html<'h3'>({ children: 'Without Fallback' }),
      new Suspense({
        onComplete: () -> trace('All resources loaded without fallback.'),
        child: new Fragment([
          new Target({ message: 'First', delay: 1000 }),
          new Target({ message: 'Second', delay: 1500 }),
          new Target({ message: 'Third', delay: 2000 }),
        ])
      })
    ]);
  }
}

class Target extends AutoComponent {
  final message:String;
  final delay:Int;

  function build():Component {
    var resource = Resource.from(this).fetch(() -> new Task(activate -> {
      Timer.delay(() -> activate(Ok(message)), delay);
    }));
    return new Html<'div'>({
      children: [
        resource.data.map(status -> switch status {
          case Loading: '...';
          case Loaded(value): value;
          case Error(e): e.message;
        }),
        ' ',
        new Html<'button'>({
          onClick: _ -> resource.refetch(),
          disabled: resource.data.map(status -> switch status {
            case Loaded(_): false;
            default: true;
          }),
          children: 'Refetch'
        })
      ]
    });
  }
}
