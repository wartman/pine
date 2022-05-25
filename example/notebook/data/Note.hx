package notebook.data;

import pine.Record;

class Note implements Record {
  @prop public final id:Null<Int>;
  @track public var title:String;
  @track public var content:String;
}
