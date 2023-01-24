package medic;

import haxe.PosInfos;
import pine.*;
import pine.html.server.*;

using pine.CoreHooks;
using pine.adaptor.Process;

// @todo: Some way to change the current Adaptor. 

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

function rendersNext<T:Component>(
  component:T,
  next:(context:Context, defer:(?next:()->Void)->Void)->Void,
  ?p:PosInfos
) {
  var comp = new AssertWrapper({
    next: next,
    child: component
  });
  mount(comp);
}

class AssertWrapper extends AutoComponent {
  public final next:(context:Context, defer:(?next:()->Void)->Void)->Void;
  final child:Component;

  function render(context:Context) {
    Hook.from(context).useNext(() -> next(context, (?next) -> {
      if (next != null) Process.from(context).defer(next);
    }));
    return child;
  }
}
