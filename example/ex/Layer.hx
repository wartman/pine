package ex;

class Layer extends Component {
  @:children @:attribute final children:Children;

  function render():Child {
    return Provider
      .provide(new LayerContext({}))
      .children(
        Html.div()
          .style(Breeze.compose(
            Layout.position('fixed'),
            Layout.overflow('x', 'hidden')
          ))
          .children(children)
      );
  }
}
