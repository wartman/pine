package notebook.ui;

import pine.*;
import pine.html.*;
import notebook.data.*;
import notebook.framework.*;

using Nuke;

class Header extends ObserverComponent {
  @track var isEditing:Bool = false;

  public function render(context:Context):Component {
    return Html.header({}, 
      Html.h1({}, 'Notebook'),
      Html.div({},
        new Button({
          onClick: () -> isEditing = true,
          child: 'Create Note'
        })
      ),
      if (isEditing)
        new NoteEditor({
          requestClose: () -> isEditing = false,
          note: new Note({
            id: null,
            title: '',
            content: ''
          })
        })
      else
        ''
    );
  }
}