package pine.html.server;

function mount(element:ElementPrimitive, render:(context:Context)->Child) {
  return Root.build(element, new ServerAdaptor(), render).create();
}

function hydrate(element:ElementPrimitive, render:(context:Context)->Child) {
  return Root.build(element, new ServerAdaptor(), render).hydrate();
}

function render(render:(context:Context)->Child) {
  var fragment = new ElementPrimitive('#fragment', {});
  Root
    .build(fragment, new ServerAdaptor(), render)
    .create();
  return fragment.toString();
}
