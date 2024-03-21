package site.island;

import pine.component.DropdownContext;
import pine.router.Link;
import site.data.MenuOption;

class DropdownMenuOption extends Component {
  @:attribute final option:MenuOption;

  function render():Child {
    var style = Breeze.compose(
      Modifier.focus(Background.color('gray', 200))
    );
    var link = switch option.type {
      case ExternalLink: 
        Html.a()
          .style(style)
          .attr('href', option.url)
          .children(option.label)
          .build();
      case PageLink:
        Link.to(option.url)
          .attr('class', style)
          .children(option.label)
          .build();
    }

    DropdownContext.from(this).register(link);

    return Html.li()
      .style(Breeze.compose(
        Flex.display(),
        Spacing.pad('x', 2),
        Spacing.pad('y', 1)
      ))
      .children(link);
  }
}
