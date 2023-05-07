package pine.component;

import pine.html.HtmlEvents;
import pine.internal.AttributeHost;

class Button extends AutoComponent implements AttributeHost {
  @:observable @:attr('class') final styles:Null<String> = null;
  @:observable @:attr final onClick:Null<EventListener> = null;
  @:observable @:attr final onDblClick:Null<EventListener> = null;
  @:observable @:attr final onKeyDown:Null<EventListener> = null;
  @:observable @:attr final onKeyPress:Null<EventListener> = null;
  @:observable @:attr final onKeyUp:Null<EventListener> = null;
  @:observable @:attr final onFocus:Null<EventListener> = null;
  @:observable @:attr final onBlur:Null<EventListener> = null;
  final children:Children = [];

  function build() {
    return new ObjectComponent({
      createObject: (adaptor, attrs) -> adaptor.createButtonObject(attrs),
      attributes: getAttributes(),
      children: children
    });
  }
}
