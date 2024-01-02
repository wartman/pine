package pine.html.client;

import js.html.Element;

function mount(el:Element, build:()->Component) {
  var root = new Root(el, build, new ClientAdaptor());
  root.mount();
  return root;
}

function hydrate(el:Element, build:()->Component) {
  var adaptor = new ClientAdaptor();
  var root = new Root(el, build, adaptor);
  root.hydrate(null, adaptor.createCursor(el));
  return root;
}
