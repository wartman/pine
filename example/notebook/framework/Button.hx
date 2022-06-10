package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class Button extends ImmutableComponent {
  @prop final child:HtmlChild;
  @prop final onClick:() -> Void;

  public function render(context:Context) {
    return new Html<'button'>({
      className: Css.atoms({
        outline: 'none',
        border: 'none',
        height: 2.rem(),
        alignItems: 'center'
      }).with(Styles.roundedSm)
        .with(Styles.bgDark)
        .with(Styles.flex),
      onclick: e -> {
        e.preventDefault();
        onClick();
      },
      children: [ child ]
    });
  }
}
