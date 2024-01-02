package pine;

import pine.Text.TextView;

class Placeholder implements ViewBuilder {
  public inline static function build() {
    return new Placeholder();
  }

  public function new() {}

  public function createView(parent:View, slot:Null<Slot>):View {
    return new TextView(parent, parent.adaptor, slot, '');
  }
}
