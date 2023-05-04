package async;

import haxe.Timer;
import js.Browser;
import pine.*;
import pine.Suspense;
import pine.html.client.Client;
import pine.signal.*;

using Kit;

function suspense() {
  var allDone = new Signal(false);

  mount(
    Browser.document.getElementById('suspense-root'),
    () -> new SuspenseBoundary({
      onComplete: () -> allDone.set(true),
      child: new Fragment([
        new Text(allDone.map(complete -> if (complete) 'all done' else 'waiting...')),
        new Suspense<String, String>({
          task: new Task(activate -> {
            Timer.delay(() -> activate(Ok('Done.')), 1000);
          }),
          child: status -> switch status {
            case Suspended: 'Pending...';
            case Active(result): switch result {
              case Ok(value): value;
              case Error(err): err;
            }
          }
        }),
        new Suspense<String, String>({
          task: new Task(activate -> {
            Timer.delay(() -> activate(Ok('Also Done.')), 2500);
          }),
          child: status -> switch status {
            case Suspended: 'Pending...';
            case Active(result): switch result {
              case Ok(value): value;
              case Error(err): err;
            }
          }
        })
      ])
    })
  );
}
