package pine.html.dom;

import js.html.Element;

using StringTools;

class DomTools {
  inline static public extern final svgNamespace = 'http://www.w3.org/2000/svg';

  public static function updateNodeAttribute(el:Element, name:String, oldValue:Dynamic, newValue:Dynamic):Void {
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
        if (name.charAt(0) == 'o' && name.charAt(1) == 'n') {
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

  static function getHtmlName(name:String) {
    if (name.startsWith('aria')) {
      return 'aria-' + name.substr(4).toLowerCase();
    }
    return name;
  }
}
