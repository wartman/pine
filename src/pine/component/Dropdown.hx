package pine.component;

import pine.component.DropdownContext;

using pine.Modifier;

class Dropdown extends Component {
  @:attribute final attachment:PositionedAttachment = ({ h: Middle, v: Bottom }:PositionedAttachment);
  @:attribute final gap:Int = 0;
  @:attribute final toggle:(context:DropdownContext)->Child;
  @:attribute final child:(context:DropdownContext)->Children;
  @:attribute final status:DropdownStatus = Closed;

  function render() {
    var dropdown = new DropdownContext(attachment, status, gap);
    var toggle = DropdownToggle.build({ child: toggle(dropdown) });
    return Provider
      .provide(dropdown)
      .children(
        toggle,
        Scope.wrap(_ -> switch dropdown.status() {
          case Open:
            DropdownPopover.build({
              getTarget: () -> toggle.getPrimitive(),
              onHide: () -> dropdown.close(),
              attachment: attachment,
              gap: gap,
              children: child(dropdown)
            });
          case Closed:
            Placeholder.build();
        })
      );
  }
}

class DropdownToggle extends Component {
  @:children @:attribute final child:Child;
  
  function render() {
    return child;
  }
}

class DropdownPopover extends Component {
  @:attribute final getTarget:()->Dynamic;
  @:attribute final onHide:()->Void;
  @:attribute final gap:Int;
  @:attribute final attachment:PositionedAttachment;
  @:children @:attribute final children:Children;

  function render() {
    var popover = Popover.build({
      getTarget: getTarget,
      gap: gap,
      attachment: attachment,
      child: children
    });
    #if (js && !nodejs)
    return popover.onMount(setup);
    #else
    return popover;
    #end
  }
  
  #if (js && !nodejs)
  var current:Null<View> = null;

  function setup() {
    var document = js.Browser.document;
    
    document.addEventListener('keydown', onKeyDown);
    document.addEventListener('click', hide);
    maybeFocusFirst();
    
    addDisposable(() -> {
      document.removeEventListener('keydown', onKeyDown);
      document.removeEventListener('click', hide);
      FocusContext.from(this).returnFocus();
    });
  }

  function hide(e:js.html.Event) {
    e.stopPropagation();
    e.preventDefault();
    onHide();
  }

  function getNextFocusedChild(offset:Int):Maybe<View> {
    var items = DropdownContext.from(this).items;
    var index = Math.ceil(items.indexOf(current) + offset);
    var item = items[index];
    
    if (item != null) {
      current = item;
      return Some(current);
    }

    return None;
  }

  function maybeFocusFirst() {
    switch getNextFocusedChild(1) {
      case Some(item):
        var el = item.getPrimitive().as(js.html.Element);
        FocusContext.from(this).focus(el);
      case None:
    }
  }

  function focusNext(e:js.html.KeyboardEvent, hideIfLast:Bool = false) {
    e.preventDefault();
    switch getNextFocusedChild(1) {
      case Some(item): 
        item.getPrimitive().as(js.html.Element)?.focus();
      case None if (hideIfLast): 
        hide(e);
      case None:
    }
  }

  function focusPrevious(e:js.html.KeyboardEvent, hideIfFirst:Bool = false) {
    e.preventDefault();
    switch getNextFocusedChild(-1) {
      case Some(item): 
        item.getPrimitive().as(js.html.Element).focus();
      case None if (hideIfFirst): 
        hide(e);
      case None:
    }
  }

  function onKeyDown(event:js.html.KeyboardEvent) {
    switch __status {
      case Pending | Disposed: return;
      default:
    }

    switch event.key {
      case 'Escape': 
        hide(event);
      case 'ArrowUp':
        focusPrevious(event);
      case 'ArrowDown':
        focusNext(event);
      case 'Tab' if (event.getModifierState('Shift')):
        focusPrevious(event, true);
      case 'Tab':
        focusNext(event, true);
      case 'Home': // ??
        maybeFocusFirst();
      default:
    }
  }
  #end
}
