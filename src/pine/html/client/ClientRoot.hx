package pine.html.client;

import js.html.Element;

function mount(element:Element, render:() -> Child) {
	return Root.build(element, new ClientAdaptor(), render).create();
}

function hydrate(element:Element, render:() -> Child) {
	return Root.build(element, new ClientAdaptor(), render).hydrate();
}
