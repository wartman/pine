package medic;

import haxe.PosInfos;
import pine.*;
import pine.html.server.*;

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
  var actual = ServerRoot.hydrate(target, component);
  Assert.equals(actual.getObject().toString(), target.toString());
}

function renders(
  component:Component,
  expected:String,
  ?p:PosInfos
):Void {
  var actual = mount(component);
  Assert.equals(actual.getObject().toString(), expected, p);
}