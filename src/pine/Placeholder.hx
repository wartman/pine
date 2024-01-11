package pine;

import pine.Text.TextView;

class Placeholder extends TextView {
  public static inline function build() {
    return new Placeholder();
  }

  public function new() {
    super('');
  }  
}
