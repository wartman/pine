package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class Grid extends ImmutableComponent {
  @prop final children:Array<HtmlChild>;

  public function render(context:Context) {
    return Html.div({
      className: Css.atoms({
        display: 'grid',
        gridTemplateColumns: repeat(4, minmax(0, 1.fr())),
        gap: 1.rem()
      }),
      // className: 'grid grid-cols-2 gap-4'
    }, ...children);
  }
}
