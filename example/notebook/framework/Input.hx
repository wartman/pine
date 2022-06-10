package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class Input extends ImmutableComponent {
  @prop final initialValue:String = '';
  @prop final onSubmit:(value:String) -> Void = null;
  @prop final onInput:(value:String) -> Void = null;
  @prop final onCancel:() -> Void = null;

  public function render(context:Context):Component {
    var value = '';

    return new Html<'input'>({
      autofocus: true,
      value: initialValue,
      name: 'input_' + new UniqueId(),
      oninput: e -> {
        var target:js.html.InputElement = cast e.target;
        value = target.value;
        if (onInput != null) {
          onInput(value);
        }
      },
      onblur: _ -> if (onCancel != null) onCancel(),
      onkeydown: e -> {
        var ev:js.html.KeyboardEvent = cast e;
        if (ev.key == 'Enter') {
          if (onSubmit != null) onSubmit(value);
        } else if (ev.key == 'Escape') {
          if (onCancel != null) onCancel();
        }
      }
    });
  }
}