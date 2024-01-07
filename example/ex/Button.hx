package ex;

import pine.html.Html;
import Breeze;
import pine.*;

class Button extends Component<Html> {
  @:children @:attribute final children:Children;

  function render(context:Context) {
    return Html.build('button').children(children);
  }
}
