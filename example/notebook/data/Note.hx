package notebook.data;

import pine.Record;

class Note implements Record {
  @prop public final id:Null<Int>;
  @track public var title:String;
  @track public var content:String;
  @track public var status:NoteStatus = Draft;

  public function toJson() {
    return {
      id: id,
      title: title,
      content: content
    };
  }
}
