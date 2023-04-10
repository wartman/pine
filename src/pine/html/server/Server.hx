package pine.html.server;

import pine.object.Object;

function mount(root:Object, build:()->Component) {
  var root = new Root(root, build, new ServerAdaptor());
  root.mount();
  return root;
}
