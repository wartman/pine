package notebook.framework;

import pine.*;
import pine.html.*;

using Nuke;

class Input extends ImmutableComponent {
  @prop final initialValue:String = '';
  @prop final onSubmit:(value:String) -> Void;
  @prop final onInput:(value:String) -> Void = null;
  @prop final onCancel:() -> Void;

  public function render(context:Context):Component {
    var value = '';

    return Html.input({
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
      onblur: _ -> onCancel(),
      onkeydown: e -> {
        var ev:js.html.KeyboardEvent = cast e;
        if (ev.key == 'Enter') {
          onSubmit(value);
        } else if (ev.key == 'Escape') {
          onCancel();
        }
      }
    });
  }
}