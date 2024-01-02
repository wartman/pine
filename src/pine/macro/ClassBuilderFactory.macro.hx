package pine.macro;

import haxe.macro.Context;

class ClassBuilderFactory {
  final builders:Array<Builder>;

  public function new(builders) {
    this.builders = builders;
  }

  public function withBuilders(...builder:Builder) {
    return new ClassBuilderFactory(builders.concat(builder));
  }

  public function from(options) {
    return new ClassBuilder({
      type: options.type,
      fields: options.fields,
      builders: builders
    });
  }

  public function fromContext() {
    return from({
      fields: Context.getBuildFields(),
      type: Context.getLocalType(),
    });
  }
}
