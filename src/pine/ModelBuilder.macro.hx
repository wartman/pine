package pine;

import pine.macro.builder.*;
import pine.macro.*;

final factory = new ClassBuilderFactory([
  new ConstantFieldBuilder(),
  new SignalFieldBuilder(),
  new ComputedFieldBuilder(),
  new ObservableFieldBuilder(),
  new ActionFieldBuilder(),
  new JsonSerializerBuilder({}),
  new ConstructorBuilder({})
]);

function build() {
  return factory.fromContext().export();
}
