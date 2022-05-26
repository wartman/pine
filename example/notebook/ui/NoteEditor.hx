package notebook.ui;

import pine.*;
import notebook.data.*;
import notebook.framework.*;

class NoteEditor extends ObserverComponent {
  @prop final note:Note = null;
  @prop final requestClose:() -> Void;
  @track var title:String;
  @track var content:String;

  public function render(context:Context):Component {
    return new Modal({
      title: title == '' ? 'Create Note' : 'Edit ${title}',
      requestClose: requestClose,
      children: [
        new Form({
          onSubmit: () -> save(context),
          children: [
            new Input({
              onInput: value -> title = value,
              initialValue: title
            }),
            new Input({
              onInput: value -> content = value,
              initialValue: content
            })
          ]
        }),
        new Button({
          onClick: () -> save(context),
          child: 'Save'
        })
      ]
    });
  }

  function save(context:Context) {
    if (note == null) {
      var store = Store.from(context);
      store.notes.push(new Note({
        id: store.uid++,
        title: title,
        content: content
      }));
    } else {
      note.title = title;
      note.content = content;
    }
    requestClose();
  }
}
