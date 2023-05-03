package async;

import haxe.Timer;
import js.Browser;
import pine.*;
import pine.html.client.Client;

using Kit;

function suspense() {
  mount(
    Browser.document.getElementById('suspense-root'),
    () -> new Suspense<String, String>({
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
    })
  );
}
