package pine.html.client;

import js.Browser;
import js.html.Element;
import pine.debug.Debug;

using StringTools;

inline extern final svgNamespace = 'http://www.w3.org/2000/svg';

class ClientAdaptor implements Adaptor {
  public function new() {}

	public function createContainerPrimitive():Dynamic {
		return createPrimitive('div');
	}

	public function createButtonPrimitive():Dynamic {
		return createPrimitive('button');
	}

	public function createInputPrimitive():Dynamic {
		return createPrimitive('input');
	}

  public function createPrimitive(name:String):Dynamic {
    return name.startsWith('svg:')
      ? Browser.document.createElementNS(svgNamespace, name.substr(4)) 
      : Browser.document.createElement(name);
  }

  public function createTextPrimitive(value:String):Dynamic {
    return Browser.document.createTextNode(value);
  }

  public function createPlaceholderPrimitive():Dynamic {
    return createTextPrimitive('');
  }

  // public function createCursor(primitive:Dynamic):Cursor {
  //   return new ClientCursor(primitive);
  // }

  public function updateTextPrimitive(primitive:Dynamic, value:String) {
    (primitive:js.html.Text).textContent = value;
  }

  // @todo: Refactor this to be better  
  public function updatePrimitiveAttribute(primitive:Dynamic, name:String, value:Dynamic, ?isHydrating:Bool) {
    var el:Element = primitive;
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
      case 'className' | 'class':
        var oldValue = el.classList.value;
        var oldNames = Std.string(oldValue ?? '').split(' ').filter(n -> n != null && n != '');
        var newNames = Std.string(value ?? '').split(' ').filter(n -> n != null && n != '');

        for (name in oldNames) {
          if (!newNames.contains(name)) {
            el.classList.remove(name);
          } else {
            newNames.remove(name);
          }
        }

        if (newNames.length > 0) {
          el.classList.add(...newNames);
        }
      case 'xmlns' if (isSvg): // skip
      case 'value' | 'selected' | 'checked' if (!isSvg):
        js.Syntax.code('{0}[{1}] = {2}', el, name, value);
      // @todo: not sure if this line is a good idea.
      case _ if (!isSvg && value != null && js.Syntax.code('{0} in {1}', name, el)):
        js.Syntax.code('{0}[{1}] = {2}', el, name, value);
      case 'dataset':
        var map:Map<String, String> = value;
        for (key => value in map) {
          if (value == null) {
            Reflect.deleteField(el.dataset, key);  
          } else {
            Reflect.setField(el.dataset, key, value);
          }
        }
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

  public function insertPrimitive(primitive:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    var el:js.html.Element = primitive;
    if (slot != null && slot.previous != null) {
      var relative:js.html.Element = slot.previous.getPrimitive();
      relative.after(el);
    } else {
      var parent:js.html.Element = findParent();
      assert(parent != null);
      parent.prepend(el);
    }
  }

  public function movePrimitive(primitive:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    var el:js.html.Element = primitive;

    if (to == null) {
      if (from != null) {
        removePrimitive(primitive, from);
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

    var relative:js.html.Element = to.previous.getPrimitive();
    assert(relative != null);
    relative.after(el);
  }

  public function removePrimitive(primitive:Dynamic, slot:Null<Slot>) {
    (primitive:Element).remove();
  }
}
