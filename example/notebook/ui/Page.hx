package notebook.ui;

import pine.*;
import notebook.framework.*;

class Page extends ImmutableComponent {
  @prop final title:String;
  @prop final children:Array<Component>;

  public function render(context:Context) {
    return new Layout({
      children: ([ 
        new Header({
          subtitle: title
        }) 
      ]:Array<Component>).concat(children)
    });
  }
}
