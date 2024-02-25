package bridge.island;

import pine.*;
import pine.html.Html;
import pine.bridge.*;
import ex.*;

function bridgeRoot() {
  Bridge
    .build({
      children: () -> Counter.build({})
    })
    .generate()
    .next(assets -> assets.process())
    .handle(result -> switch result {
      case Ok(_): trace('ok');
      case Error(error): trace(error.message);
    });
}

class Counter extends Island {
  @:signal final count:Int = 0;

  function render():Child {
    trace('hm');
    return Html.template(<>
      <p>{count.map(Std.string)}</p>
      <Button action={() -> count.update(i -> i++)}>"Increment"</Button>
    </>);
  }
}
