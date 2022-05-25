package notebook.framework;

import js.Browser;
import pine.*;
import pine.html.*;

using Nuke;

class Modal extends ImmutableComponent {
  @prop final title:String;
  @prop final requestClose:() -> Void;
  @prop final children:Array<HtmlChild>;

  public function render(context:Context):Component {
    return new Portal({
      el: Browser.document.getElementById('portal'),
      child: new Overlay({
        onClick: requestClose,
        child: new Box({
          onClick: e -> e.stopPropagation(),
          className: Css.atoms({
            maxWidth: 500.px()
          }),
          children: [
            new BoxHeader({
              children: [
                new BoxTitle({ child: title }),
                new Button({
                  onClick: requestClose,
                  child: 'X'
                })
              ]
            }),
            new BoxContent({
              children: children
            })
          ]
        })
      })
    });
  }
}