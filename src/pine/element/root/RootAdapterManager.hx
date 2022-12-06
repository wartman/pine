package pine.element.root;

import haxe.ds.Option;
import pine.adapter.Adapter;

class RootAdapterManager implements AdapterManager {
  final adapter:Adapter;

  public function new(adapter) {
    this.adapter = adapter;
  }

  public function get():Option<Adapter> {
    return Some(adapter);
  }

  public function update(_) {}

  public function dispose() {}
}
