package bridge.page;

import pine.html.Html;
import pine.*;
import pine.bridge.*;
import bridge.layout.*;
import bridge.island.*;

class HomePage extends Page<'/'> {
  public function render():Child {
    return Html.template(<MainLayout title="Home">
      <Counter />
      <OtherThing count={20} />
    </MainLayout>);
  }
}