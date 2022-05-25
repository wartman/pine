package notebook.ui;

import pine.*;
import notebook.data.*;
import notebook.framework.*;

class App extends ImmutableComponent {
  public function render(context:Context):Component {
    return new Store.StoreProvider({
      create: () -> new Store({ notes: [
        new Note({ id: 0, title: 'Foo', content: 'foo' }),
        new Note({ id: 1, title: 'Bar', content: 'bar' })
      ] }),
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
