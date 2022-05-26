package notebook.route;

import notebook.data.NoteStatus;

enum Route {
  Home;
  Note(id:Int);
  NoteList(?filter:NoteStatus);
  About;
}

