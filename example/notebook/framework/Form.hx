package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class Form extends ImmutableComponent {
  @prop final onSubmit:() -> Void;
  @prop final children:Array<HtmlChild>;

  public function render(context:Context):Component {
    return new Html<'form'>({
      onsubmit: e -> {
        e.preventDefault();
        onSubmit();
      },
      onkeydown: e -> {
        var ev:js.html.KeyboardEvent = cast e;
        if (ev.key == 'Enter') {
          onSubmit();
        }
      },
      children: children
    });
  }
}
