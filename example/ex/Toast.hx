package ex;

import pine.*;
import pine.html.*;
import Breeze;

using ex.BreezePlugin;

class ToastManager extends Model {
  @:signal public final messages:Array<String>;

  @:action
  public function addMessage(message:String) {
    messages.update(messages -> messages.concat([ message ]));
  }
  
  @:action
  public function removeMessage(message:String) {
    messages.update(messages -> messages.filter(m -> m != message));
  }
}

class Toast extends Component {
  @:children @:attribute final children:Children;
  
  function render(context:Context) {
    var manager = new ToastManager({ messages: [] });
    var hasMessages = manager.messages.map(messages -> messages.length > 0); 

    return Provider.provide(manager).children(
      Show.when(hasMessages, _ -> {
        Portal.into(
          js.Browser.document.getElementById('portal'),
          Html.build('div')
            .style(Breeze.compose(
              Flex.display()
            ))
            .children(
              For.each(manager.messages, message -> ToastItem.build({ message: message }))
            )
        );
      }),
      children
    );
  }
}

class ToastItem extends Component<Html> {
  @:attribute final message:String;

  function render(context:Context) {
    var manager = context.get(ToastManager);

    return Html.build('div')
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
        Html.build('div').children(message),
        Button.build({
          action: () -> manager?.removeMessage(message),
          child: 'Close'
        })
      );
  }  
}
