package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class BoxHeader extends ImmutableComponent {
  @prop final children:Array<HtmlChild>;
  
  public function render(context:Context) {
    return Html.header({
      className: Css.atoms({
        width: 100.pct(),
        alignItems: 'center'
      }).with(Styles.gapBottom)
        .with(Styles.flex)
    }, ...children);
  }
}
