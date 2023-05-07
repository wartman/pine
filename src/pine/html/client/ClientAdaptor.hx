package pine.html.client;

import js.Browser;
import js.html.Element;
import pine.debug.Debug;
import pine.internal.*;
import pine.internal.Slot;

using StringTools;

inline extern final svgNamespace = 'http://www.w3.org/2000/svg';

class ClientAdaptor implements Adaptor {
  public function new() {}

	public function createContainerObject(attrs:{}):Dynamic {
		return createCustomObject('div', attrs);
	}

	public function createButtonObject(attrs:{}):Dynamic {
		return createCustomObject('button', attrs);
	}

	public function createInputObject(attrs:{}):Dynamic {
		return createCustomObject('input', attrs);
	}

  public function createCustomObject(name:String, initialAttrs:{}):Dynamic {
    return name.startsWith('svg:')
      ? Browser.document.createElementNS(svgNamespace, name.substr(4)) 
      : Browser.document.createElement(name);
  }

  public function createTextObject(value:String):Dynamic {
    return Browser.document.createTextNode(value);
  }

  public function createPlaceholderObject():Dynamic {
    return createTextObject('');
  }

  public function createCursor(object:Dynamic):Cursor {
    return new ClientCursor(object);
  }

  public function updateTextObject(object:Dynamic, value:String) {
    (object:js.html.Text).textContent = value;
  }

  // @todo: Refactor this to be better  
  public function updateObjectAttribute(object:Dynamic, name:String, value:Dynamic, ?isHydrating:Bool) {
    var el:Element = object;
    var isSvg = el.namespaceURI == svgNamespace;
    
    if (isHydrating == true) {
      name = getHtmlName(name);
      // Only bind events.
      // @todo: Setting events this way feels questionable.
      if (name.startsWith('on')) {
        var name = name.toLowerCase();
        if (value == null) {
          Reflect.setField(el, name, cast null);
        } else {
          Reflect.setField(el, name, value);
        }
      }
      return;
    }

    switch name {
      case 'className':
        updateObjectAttribute(el, 'class', value);
      case 'xmlns' if (isSvg): // skip
      case 'value' | 'selected' | 'checked' if (!isSvg):
        js.Syntax.code('{0}[{1}] = {2}', el, name, value);
      case _ if (!isSvg && js.Syntax.code('{0} in {1}', name, el)):
        js.Syntax.code('{0}[{1}] = {2}', el, name, value);
      default:
        name = getHtmlName(name);
        // @todo: Setting events this way feels questionable.
        if (name.startsWith('on')) {
          var name = name.toLowerCase();
          if (value == null) {
            Reflect.setField(el, name, cast null);
          } else {
            Reflect.setField(el, name, value);
          }
        } else if (value == null || (Std.is(value, Bool) && value == false)) {
          el.removeAttribute(name);
        } else if (Std.is(value, Bool) && value == true) {
          el.setAttribute(name, name);
        } else {
          el.setAttribute(name, value);
        }
    }
  }

  // @todo: Figure out how to use the @:html attributes for this instead.
  function getHtmlName(name:String) {
    if (name.startsWith('aria')) {
      return 'aria-' + name.substr(4).toLowerCase();
    }
    return name;
  }

  public function insertObject(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    var el:js.html.Element = object;
    if (slot != null && slot.previous != null) {
      var relative:js.html.Element = slot.previous.getObject();
      relative.after(el);
    } else {
      var parent:js.html.Element = findParent();
      assert(parent != null);
      parent.prepend(el);
    }
  }

  public function moveObject(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    var el:js.html.Element = object;

    if (to == null) {
      if (from != null) {
        removeObject(object, from);
      }
      return;
    }

    if (from != null && !from.indexChanged(to)) {
      return;
    }

    if (to.previous == null) {
      var parent:js.html.Element = findParent();
      assert(parent != null);
      parent.prepend(el);
      return;
    }

    var relative:js.html.Element = to.previous.getObject();
    assert(relative != null);
    relative.after(el);
  }

  public function removeObject(object:Dynamic, slot:Null<Slot>) {
    (object:Element).remove();
  }
}
