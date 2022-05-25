package notebook.ui;

import pine.*;
import notebook.data.*;
import notebook.framework.*;

class NoteItem extends ObserverComponent {
  @prop final note:Note;
  @track var isEditing:Bool = false;

  public function render(context:Context):Component {
    return new Box({
      children: [
        new BoxHeader({
          children: [
            new BoxTitle({ child: note.title }),
            new Button({
              onClick: () -> isEditing = true,
              child: 'Edit'
            }),
            new Button({
              onClick: () -> Store.from(context).notes.remove(note),
              child: 'X'
            })
          ]
        }),
        new BoxContent({
          children: [ note.content ]
        }),
        if (isEditing)
          new NoteEditor({
            requestClose: () -> isEditing = false,
            note: note
          })
        else
          ''
      ]
    });
  }
}
