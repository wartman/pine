package bridge.island;

import pine.*;
import pine.html.Html;
import pine.bridge.*;
import ex.*;

#if !pine.client
function bridgeRoot() {
  Bridge
    .build({
      client: {
        hxml: 'dependencies',
      },
      children: () -> Html.html()
        .children(
          Html.head().children(
            Html.link().attr('rel', 'stylesheet').attr('href', 'styles.css')
          ),
          Html.body().children(
            Counter.build({}),
            Html.script().attr('src', 'app.js')
          )
        )
    })
    .generate()
    .next(assets -> assets.process())
    .handle(result -> switch result {
      case Ok(_): trace('ok');
      case Error(error): trace(error.message);
    });
}
#end

class Counter extends Island {
  @:signal final count:Int = 0;

  function render():Child {
    return Html.template(<>
      <p>{count.map(Std.string)}</p>
      <Button action={() -> count.update(i -> i + 1)}>"Increment"</Button>
    </>);
  }
}
