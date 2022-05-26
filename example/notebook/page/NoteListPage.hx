package notebook.page;

import pine.*;
import notebook.ui.*;
import notebook.data.*;

class NoteListPage extends ObserverComponent {
  @prop final status:Null<NoteStatus>;

  public function render(context:Context) {
    var notes:Array<Note> = Store.from(context).notes;
    
    if (status != null) {
      notes = notes.filter(note -> note.status == status);
    }

    return new Page({
      title: 'Notes | ${status == null ? 'All' : status}',
      children: [
        new NoteList({ notes: notes })
      ]
    });
  }
}
