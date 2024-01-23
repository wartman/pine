package ex;

import pine.*;
import pine.html.*;
import Breeze;

using ex.BreezePlugin;

class ToastManager extends Model {
  @:signal public final messages:Array<String>;

  public function addMessage(message:String) {
    messages.update(messages -> messages.concat([ message ]));
  }
  
  public function removeMessage(message:String) {
    messages.update(messages -> messages.filter(m -> m != message));
  }
}

class Toast extends Component {
  @:children @:attribute final children:Children;
  
  function render():Child {
    var manager = new ToastManager({ messages: [] });
    var target = js.Browser.document.getElementById('portal');
    var hasMessages = manager.messages.map(messages -> messages.length > 0); 

    return Provider.provide(manager).children(
      Show.when(hasMessages, () -> {
        Portal.into(target, () -> {
          Html.div().style(Breeze.compose(
            Flex.display()
          )).children(
            For.each(manager.messages, message -> ToastItem.build({ message: message }))
          );
        });
      }),
      children
    );
  }
}

class ToastItem extends Component {
  @:attribute final message:String;

  function render():Child {
    var manager = get(ToastManager);

    return Html.div()
      .style(Breeze.compose(
        Sizing.height('min', 5),
        Spacing.pad(3),
        Border.color('black', 0),
        Border.width(3),
        Border.radius(2),
        Background.color('gray', 300),
        Flex.display()
      ))
      .children(
        Html.div().children(message),
        Button.build({
          action: () -> manager?.removeMessage(message),
          child: 'Close'
        })
      );
  }  
}
