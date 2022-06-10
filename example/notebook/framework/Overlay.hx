package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class Overlay extends ImmutableComponent {
  @prop final onClick:() -> Void;
  @prop final child:HtmlChild;

  public function render(context:Context):Component {
    return new Html<'div'>({
      onclick: _ -> onClick(),
      className: Css.atoms({
        backgroundColor: rgba(0, 0, 0, 0.9),
        position: 'absolute',
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,
        alignItems: 'center',
        justifyContent: 'center'
      }).with(Styles.flex),
      children: [child]
    });
  }
}
