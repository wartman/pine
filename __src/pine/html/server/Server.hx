package pine.html.server;

import pine.object.Object;

function mount(object:Object, build:()->Component) {
  var root = new Root(object, build, new ServerAdaptor());
  root.mount();
  return root;
}

function hydrate(object:Object, build:()->Component) {
  var adaptor = new ServerAdaptor();
  var root = new Root(object, build, adaptor);
  root.hydrate(null, adaptor.createCursor(object));
  return root;
}
