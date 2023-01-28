package medic;

import haxe.PosInfos;
import pine.*;
import pine.html.server.*;

using pine.adaptor.Process;

function mount(component:Component) {
  var object = new HtmlElementObject('#document', {});
  var root = ServerRoot.mount(object, component);
  return root;
}

function hydrates(
  component:Component,
  target:HtmlElementObject,
  ?p:PosInfos
) {
  var expected = target.toString();
  var actual = ServerRoot.hydrate(target, component);
  Assert.equals(actual.getObject().toString(), expected);
}

function renders(
  component:Component,
  expected:String,
  ?p:PosInfos
):Void {
  var actual = mount(component);
  Assert.equals(actual.getObject().toString(), expected, p);
}

function rendersAsync(
  component:Component,
  next:(root:Element)->Void
) {
  var root = mount(component);
  root.getAdaptor().afterRebuild(() -> next(root));  
}

function toString(element:Element):String {
  return (element.getObject():HtmlElementObject).toString();
}
