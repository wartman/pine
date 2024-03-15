package pine.component;

class DropdownItem extends Component {
  @:children @:attribute final child:Child;

  function render():Child {
    DropdownContext.from(this).register(this);
    return child;
  }
}
