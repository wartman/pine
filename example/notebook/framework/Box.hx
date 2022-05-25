package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class Box extends ImmutableComponent {
  @prop final className:ClassName = null;
  @prop final children:Array<HtmlChild>;
  @prop final onClick:(e:js.html.Event) -> Void = null;

  public function render(context:Context):Component {
    return Html.div({
      onclick: onClick,
      className: Styles.rounded
        .with(Styles.bgWhite)
        .with(className)
      // className: 'p-6 bg-white rounded-xl'
    }, ...children);
  }
}
