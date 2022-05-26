package notebook.ui;

import pine.*;
import notebook.route.*;
import notebook.page.*;

class RouteHandler extends ObserverComponent {
  @prop final router:Router;

  public function render(context:Context) {
    return switch router.get() {
      case Home:
        new HomePage({});
      case NoteList(filter):
        new NoteListPage({ status: filter });
      default: throw 'assert';
    }
  }
}
