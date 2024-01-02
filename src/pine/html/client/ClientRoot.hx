package pine.html.client;

import js.html.Element;

function mount(element:Element, render:(context:Context)->Builder) {
  return Root.build(element, new ClientAdaptor(), render).create();
}
