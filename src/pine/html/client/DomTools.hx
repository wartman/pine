package pine.html.client;

import js.html.Element;

using StringTools;

inline extern final svgNamespace = 'http://www.w3.org/2000/svg';

// @todo: We should investigate if there's a better way to
// do this. I'm especially unsure about directly setting
// functions for event handlers.
function updateNodeAttribute(el:Element, name:String, oldValue:Null<Dynamic>, newValue:Null<Dynamic>):Void {
  var isSvg = el.namespaceURI == svgNamespace;
  switch name {
    case 'ref' | 'key':
    // noop
    case 'className':
      updateNodeAttribute(el, 'class', oldValue, newValue);
    case 'xmlns' if (isSvg): // skip
    case 'value' | 'selected' | 'checked' if (!isSvg):
      js.Syntax.code('{0}[{1}] = {2}', el, name, newValue);
    case _ if (!isSvg && js.Syntax.code('{0} in {1}', name, el)):
      js.Syntax.code('{0}[{1}] = {2}', el, name, newValue);
    default:
      name = getHtmlName(name);
      // @todo: Setting events this way feels questionable.
      if (name.startsWith('on')) {
        var name = name.toLowerCase();
        if (newValue == null) {
          Reflect.setField(el, name, cast null);
        } else {
          Reflect.setField(el, name, newValue);
        }
      } else if (newValue == null || (Std.is(newValue, Bool) && newValue == false)) {
        el.removeAttribute(name);
      } else if (Std.is(newValue, Bool) && newValue == true) {
        el.setAttribute(name, name);
      } else {
        el.setAttribute(name, newValue);
      }
  }
}

// @todo: Figure out how to use the @:html attributes for this instead.
private function getHtmlName(name:String) {
  if (name.startsWith('aria')) {
    return 'aria-' + name.substr(4).toLowerCase();
  }
  return name;
}
