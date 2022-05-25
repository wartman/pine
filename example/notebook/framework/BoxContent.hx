package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class BoxContent extends ImmutableComponent {
  @prop final children:Array<HtmlChild>;
  
  public function render(context:Context) {
    return Html.div({
      className: Css.atoms({
        width: 100.pct(),
        ':last-child': {
          marginBottom: 0
        }
      }).with(Styles.gapBottom)
    }, ...children);
  }
}
