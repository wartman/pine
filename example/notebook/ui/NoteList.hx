package notebook.ui;

import pine.*;
import notebook.data.*;
import notebook.framework.*;

class NoteList extends ObserverComponent {
  @prop final store:Store;

  public function render(context:Context):Component {
    return new Grid({
      children: [ 
        for (note in store.notes) new NoteItem({ note: note, key: note.id }) 
      ]
    });
  }
}
