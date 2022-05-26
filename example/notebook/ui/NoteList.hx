package notebook.ui;

import pine.*;
import notebook.data.*;
import notebook.framework.*;

class NoteList extends ImmutableComponent {
  @prop final notes:Array<Note>;

  public function render(context:Context):Component {
    return if (notes.length == 0)
      new Box({
        status: Deactivated,
        children: [ 'No notes' ]
      });
    else
      new Grid({
        children: [
          for (note in notes) new NoteItem({ note: note, key: note.id }) 
        ]
      });
  }
}
