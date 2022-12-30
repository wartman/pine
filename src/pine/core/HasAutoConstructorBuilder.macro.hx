package pine.core;

import pine.macro.ClassBuilder;

function build() {
  var builder = ClassBuilder.fromContext();
  var properties = new PropertyBuilder(builder.getFields());
  var initType = properties.getPropsType();
  var cls = haxe.macro.Context.getLocalClass().get();

  if (cls.superClass != null) {
    haxe.macro.Context.error(
      'HasAutoConstructor currently cannot be used on a class with a superclasses',
      cls.pos
    );
  }

  switch builder.findField('new') {
    case Some(field):
      haxe.macro.Context.error(
        'You cannot use HasAutoConstructor with a user-defined constructor',
        field.pos
      );
    case None:
  }

  builder.add(macro class {
    public function new(props:$initType) {
      @:mergeBlock ${properties.getInitializers()}
    }
  });

  return builder.merge(properties).export();
}
