package pine.element.root;

import haxe.ds.Option;
import pine.adaptor.Adaptor;

class RootAdaptorManager implements AdaptorManager {
  final adaptor:Adaptor;

  public function new(adaptor) {
    this.adaptor = adaptor;
  }

  public function get():Option<Adaptor> {
    return Some(adaptor);
  }

  public function update(_) {}

  public function dispose() {}
}
