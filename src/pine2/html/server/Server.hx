package pine2.html.server;

import pine2.object.Object;

function mount(root:Object, build:()->Component) {
  var root = new Root(root, build, new ServerAdaptor());
  root.mount();
  return root;
}
