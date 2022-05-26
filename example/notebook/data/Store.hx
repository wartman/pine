package notebook.data;

import pine.*;
import haxe.Json;

using Reflect;

typedef StoreProvider = Provider<Store>;

class Store implements Record {
  static inline final NOTEBOOK_STORE = 'notebook-store';

  public static function load() {
    var data = js.Browser.window.localStorage.getItem(NOTEBOOK_STORE);
    var store = if (data == null) {
      new Store({uid: 0, notes: []});
    } else {
      fromJson(Json.parse(data));
    }

    TrackingTools.track(() -> {
      js.Browser.window.localStorage.setItem(NOTEBOOK_STORE, Json.stringify(store.toJson()));
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
    return StoreProvider.from(context);
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
