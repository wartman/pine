package pine.element.core;

import haxe.ds.Option;
import pine.adapter.Adapter;

class CoreAdapterManager implements AdapterManager {
  var adapter:Option<Adapter> = None;

  public function new() {}
  
  public function get():Option<Adapter> {
    return adapter;
  }

  public function update(parent:Null<Element>) {
    if (parent == null) {
      adapter = None;
      return;
    } 
      
    this.adapter = parent.getAdapter();
  }

  public function dispose() {
    this.adapter = None;
  }
}
