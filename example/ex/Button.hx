package ex;

import Breeze;
import pine.*;
import pine.html.Html;
import pine.signal.*;

using ex.BreezePlugin;

class Button extends Component {
  @:observable final selected:Bool = false;
  @:observable final disabled:Bool = false;
  @:attribute final action:()->Void;
  @:children @:attribute var child:Child;

  public function render():Child {
    return Html.button()
      .style(new Computation<ClassName>(() -> [
        Spacing.pad('x', 3),
        Spacing.pad('y', 1),
        Border.radius(2),
        Border.width(.5),
        Border.color('black', 0),
        Modifier.disabled(
          Effect.opacity(50),
          Interactive.cursor('not-allowed')
        ),
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
      .attr('disabled', disabled)
      .on(Click, _ -> action())
      .children(child);
  }
}
