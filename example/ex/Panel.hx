package ex;

import pine.html.HtmlEvents;

class Panel extends Component {
  @:attribute final styles:ClassName = null;
  @:attribute final onClick:(e:Event)->Void = null;
  @:children @:attribute final children:Children;

  function render():Child {
    return Html.div()
      .style(Breeze.compose(
        styles,
        Spacing.pad('x', 1),
        Spacing.pad('y', 1),
        Border.radius(2),
        Border.width(.5),
        Border.color('black', 0),
      ))
      .on(Click, onClick)
      .children(children);
  }
}
