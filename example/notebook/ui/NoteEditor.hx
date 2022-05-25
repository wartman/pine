package notebook.ui;

import pine.*;
import notebook.data.*;
import notebook.framework.*;

class NoteEditor extends ObserverComponent {
  @prop final note:Note;
  @prop final requestClose:() -> Void;

  public function render(context:Context):Component {
    var prevTitle = note.title;
    var prevContent = note.content;

    return new Modal({
      title: note.title == '' ? 'Create Note' : 'Edit ${note.title}',
      requestClose: requestClose,
      children: [
        new Input({
          onSubmit: value -> note.title = value,
          onInput: value -> note.title = value,
          onCancel: () -> note.title = prevTitle,
          initialValue: note.title
        }),
        new Input({
          onSubmit: value -> note.content = value,
          onInput: value -> note.content = value,
          onCancel: () -> note.content = prevContent,
          initialValue: note.content
        }),
        new Button({
          onClick: () -> {
            if (note.id == null) {
              var store = Store.from(context);
              store.notes.push(new Note({
                id: store.id++,
                title: note.title,
                content: note.content
              }));
            }
            requestClose();
          },
          child: 'Save'
        })
      ]
    });
  }
}
