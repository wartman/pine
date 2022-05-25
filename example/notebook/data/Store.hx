package notebook.data;

import pine.*;

typedef StoreProvider = Provider<Store>;

class Store implements Record {
  public static function from(context:Context) {
    return StoreProvider.from(context);
  }

  @track public var id:Int = 0;
  @track public var notes:Array<Note>;
}
