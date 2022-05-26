package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

enum BoxStatus {
  Normal;
  Deactivated;
}

class Box extends ImmutableComponent {
  @prop final className:ClassName = null;
  @prop final children:Array<HtmlChild>;
  @prop final status:BoxStatus = Normal;
  @prop final onClick:(e:js.html.Event) -> Void = null;
  @prop final onDblClick:(e:js.html.Event) -> Void = null;

  public function render(context:Context):Component {
    return Html.div({
      onclick: onClick,
      ondblclick: onDblClick,
      className: Styles.rounded
        .with(switch status {
          case Normal: Styles.bgWhite;
          case Deactivated: Styles.bgGrey;
        })
        .with(className)
      // className: 'p-6 bg-white rounded-xl'
    }, ...children);
  }
}
