package pine.internal;

function build() {
  var builder = PropertyBuilder.fromContext();

  switch builder.findField('getComponentType') {
    case Some(_): return builder.export();
    case None:
  }

  builder.add(macro class {
    public static final componentType:pine.internal.UniqueId = new pine.internal.UniqueId();

    public function getComponentType():pine.internal.UniqueId {
      return componentType;
    }
  });

  return builder.export();
}
