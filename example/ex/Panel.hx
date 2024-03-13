package ex;

class Panel extends Component {
  @:children @:attribute final children:Children;

  function render():Child {
    return Html.div()
      .style(Breeze.compose(
        Spacing.pad('x', 1),
        Spacing.pad('y', 1),
        Border.radius(2),
        Border.width(.5),
        Border.color('black', 0),
      ))
      .children(children);
  }
}
