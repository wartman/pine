package notebook.data;

import js.Browser.window;
import pine.*;

using Reflect;
using haxe.Json;

typedef Provider = pine.Provider<Store>;

class Store implements Record {
  static inline final NOTEBOOK_STORE = 'notebook-store';

  public static function load() {
    var data = window.localStorage.getItem(NOTEBOOK_STORE);
    var store = if (data == null) {
      new Store({uid: 0, notes: []});
    } else {
      fromJson(data.parse());
    }

    TrackingTools.track(() -> {
      window.localStorage.setItem(NOTEBOOK_STORE, store.toJson().stringify());
    });

    return store;
  }

  public static function fromJson(data:Dynamic) {
    return new Store({
      uid: data.field('uid'),
      notes: (data.field('notes') : Array<Dynamic>).map(Note.new),
    });
  }
  
  public static function from(context:Context) {
    return Provider.from(context);
  }

  @track public var uid:Int = 0;
  @track public var notes:Array<Note>;

  public function toJson() {
    return {
      uid: uid,
      notes: notes.map(note -> note.toJson())
    }
  }
}
