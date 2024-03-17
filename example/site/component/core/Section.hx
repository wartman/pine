package site.component.core;

import site.style.*;

class Section extends Component {
  @:attribute final styles:ClassName = null;
  @:attribute final constrain:Bool = false;
  @:children @:attribute final children:Children;

  function render():Child {
    return Html.section()
      .style(Breeze.compose(
        styles,
        Flex.display(),
        Flex.gap(3),
        Flex.direction('column'),
        if (constrain) Core.centered else null
      ))
      .children(children);
  }
}
