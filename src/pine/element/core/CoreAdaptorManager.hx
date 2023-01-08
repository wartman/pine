package pine.element.core;

import haxe.ds.Option;
import pine.adaptor.Adaptor;

class CoreAdaptorManager implements AdaptorManager {
  var adaptor:Option<Adaptor> = None;

  public function new() {}
  
  public function get():Option<Adaptor> {
    return adaptor;
  }

  public function update(parent:Null<Element>) {
    if (parent == null) {
      adaptor = None;
      return;
    } 
      
    this.adaptor = parent.adaptor.get();
  }

  public function dispose() {
    this.adaptor = None;
  }
}
