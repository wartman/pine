package notebook.page;

import pine.*;
import notebook.ui.*;
import notebook.data.Store;

class HomePage extends ObserverComponent {
  public function render(context:Context) {
    return new Page({
      title: 'Home',
      children: [
        new NoteList({ notes: Store.from(context).notes })
      ]
    });
  }
}
