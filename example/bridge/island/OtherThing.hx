package bridge.island;

import pine.*;
import pine.html.Html;
import pine.bridge.*;

class OtherThing extends Island {
  @:attribute final count:Int = 1;

  function render():Child {
    return Html.template(<div>
      "This is a wrapped island:"
      <Counter count=count />
    </div>);
  }
}
