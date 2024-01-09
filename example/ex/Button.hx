package ex;

import Breeze;
import pine.*;
import pine.html.Html;
import pine.signal.*;

using ex.BreezePlugin;

class Button extends Component<Html> {
  @:observable final selected:Bool = false;
  @:attribute final action:()->Void;
  @:children @:attribute var child:Child;

  function render(_) {
    return Html.build('button')
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
