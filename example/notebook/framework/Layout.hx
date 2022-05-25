package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class Layout extends ImmutableComponent {
  @prop final children:Array<HtmlChild>;

  public function render(context:Context):Component {
    return Html.main({
      className: Css.atoms({
        maxWidth: 900.px(),
        margin: [ 0.px(), 'auto' ]
      })
    }, ...children);
  }
}
