package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class BoxTitle extends ImmutableComponent {
  @prop final child:String;

  public function render(context:Context):Component {
    return new Html<'h2'>({
      className: Css.atoms({ flexGrow: 3 }),
      children: [ child ]
    });
  }
}
