package notebook.ui;

import pine.*;
import notebook.data.*;
import notebook.framework.*;

class App extends ImmutableComponent {
  public function render(context:Context):Component {
    return new Store.StoreProvider({
      create: () -> Store.load(),
      dispose: store -> store.dispose(),
      render: store -> new Layout({
        children: [
          new Header({}),
          new NoteList({ store: store })
        ]
      })
    });
  }
}
