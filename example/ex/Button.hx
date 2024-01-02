package ex;

import pine.html.Html;
import Breeze;
import pine.*;

class Button extends Component<Html> {
  function render(context:Context) {
    return Html.build('button');
  }
}
