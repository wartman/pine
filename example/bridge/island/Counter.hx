package bridge.island;

import pine.*;
import pine.html.Html;
import pine.bridge.*;
import ex.*;

class Counter extends Island {
  @:signal final count:Int = 0;

  function render():Child {
    return Html.template(<>
      <p>{count.map(Std.string)}</p>
      <Button action={() -> count.update(i -> i + 1)}>"Increment"</Button>
    </>);
  }
}
