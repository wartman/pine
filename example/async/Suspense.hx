package async;

import pine.signal.Signal;
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
    final withFallbackStatus = new Signal(false);
    final withoutFallbackStatus = new Signal(false);
    return new Fragment([
      new Html<'h3'>({ 
        children: [
          'With Fallback ',
          withFallbackStatus.map(status -> switch status {
            case true: '✔';
            case false: '❌';
          })
        ]
      }),
      new Html<'p'>({
        children: '
          If we provide a "fallback" property in our Suspense component,
          all of the component\'s children will be replaced by the
          fallback every time a suspense is triggered. 
        '
      }),
      new Suspense({
        onComplete: () -> withFallbackStatus.set(true),
        onSuspended: () -> withFallbackStatus.set(false),
        fallback: () -> 'loading...',
        child: new Fragment([
          new Target({ message: 'First', delay: 1000 }),
          new Target({ message: 'Second', delay: 1500 }),
          new Target({ message: 'Third', delay: 2000 }),
        ])
      }),
      new Html<'h3'>({ 
        children: [
          'Without Fallback',
          withoutFallbackStatus.map(status -> switch status {
            case true: '✔';
            case false: '❌';
          })
        ]
      }),
      new Html<'p'>({
        children: '
          If we don\'t provide a fallback, then the suspended
          components will be displayed as normal. This can still
          be useful, as we can use the `onComplete` and `onSuspended`
          props to track if any child Resources are loading.
        '
      }),
      new Suspense({
        onComplete: () -> withoutFallbackStatus.set(true),
        onSuspended: () -> withoutFallbackStatus.set(false),
        child: new Fragment([
          new Target({ message: 'First', delay: 1000 }),
          new Target({ message: 'Second', delay: 1500 }),
          new Target({ message: 'Third', delay: 2000 }),
        ])
      }),
      new Html<'h3'>({
        children: 'Other Features'
      }),
      new OtherFeatures({})
    ]);
  }
}

class Target extends AutoComponent {
  final message:String;
  final delay:Int;

  function build():Component {
    var resource = Resource.from(this).fetch(() -> new Task(activate -> {
      Timer.delay(() -> activate(Ok(message)), delay);
    }), {
      hydrate: () -> message,
      loading: () -> trace('Loading started...'),
      loaded: value -> trace('$value loaded'),
      errored: error -> trace(error.message)
    });
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

class OtherFeatures extends AutoComponent {
  function build() {
    var res = Resource.from(this).fetch(() -> new Task(activate -> {
      Timer.delay(() -> activate(Ok('Loaded')), 1000);
    }));
    return new Suspense({
      propagateSuspension: false,
      child: new Show(res.loading, () -> 'Loading...', () -> res()) 
    });
  }
}
