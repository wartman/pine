package notebook.ui;

import notebook.route.Router;
import pine.*;
import pine.html.*;
import notebook.framework.*;

using Nuke;

class Header extends ObserverComponent {
  @prop final subtitle:String;
  @track var isEditing:Bool = false;

  public function render(context:Context):Component {
    return new Html<'header'>({
      className: Styles.flex,
      children: [
        new Html<'h1'>({
          onclick: _ -> Router.from(context).set(Home),
          children: [ 'Notebook' ]
        }),
        new Html<'h2'>({ children: [ subtitle ] }),
        new Html<'div'>({
          children: [
            new Button({
              onClick: () -> Router.from(context).set(NoteList(Draft)),
              child: 'Draft Notes'
            }),
            new Button({
              onClick: () -> Router.from(context).set(NoteList(Completed)),
              child: 'Completed Notes'
            }),
            new Button({
              onClick: () -> isEditing = true,
              child: 'Create Note'
            })
          ]
        }),
        if (isEditing)
          new NoteEditor({
            requestClose: () -> isEditing = false,
            title: '',
            content: ''
          })
        else
          null
      ]
    });
  }
}