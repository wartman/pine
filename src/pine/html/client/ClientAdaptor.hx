package pine.html.client;

import js.html.Node;
import js.Browser;
import js.html.Element;
import pine.debug.Debug;

using StringTools;

inline extern final svgNamespace = 'http://www.w3.org/2000/svg'; 

class ClientAdaptor implements Adaptor {
  var isHydrating:Bool = false;

  public function new() {}
  
  public function hydrate(scope:()->Void) {
    isHydrating = true;
    scope();
    isHydrating = false;
  }

  // Note: This hydration method is extremely fragile right now.
  // Need to look into some ways to add verification.
  //
  // That said, it *should* work so long as the client and server HTML
  // is identical.
  function hydrateNearestPrimitive(slot:Slot, findParent:()->Dynamic):Dynamic {
    var prev:Null<Node> = slot.previous;
    if (prev == null) {
      return skipComments((findParent():Node).firstChild);
    }
    return skipComments(prev.nextSibling);
  }

  function skipComments(node:Null<Node>) {
    // We're using comments to mark where string nodes start and end,
    // which is probably quite fragile.
    //
    // A better method might be to have *all* components use 
    // comment markers, perhaps even sending their hydration data
    // next to them. This will take some more thinking, but would 
    // open up stuff like Islands.
    if (node == null) return null;
    if (node.nodeType == Node.COMMENT_NODE) {
      return skipComments(node.nextSibling);
    }
    return node;
  }

  public function createContainerPrimitive(slot:Slot, findParent:()->Dynamic):Dynamic {
    return createPrimitive('div', slot, findParent);
  }

  public function createPrimitive(name:String, slot:Slot, findParent:()->Dynamic):Dynamic {
    if (isHydrating) {
      // @todo: some validation here.
      return hydrateNearestPrimitive(slot, findParent);
    }
    return name.startsWith('svg:')
      ? Browser.document.createElementNS(svgNamespace, name.substr(4)) 
      : Browser.document.createElement(name);
  }

  public function createTextPrimitive(value:String, slot:Slot, findParent:()->Dynamic):Dynamic {
    if (isHydrating) {
      // @todo: some validation here.
      return hydrateNearestPrimitive(slot, findParent);
    }
    return Browser.document.createTextNode(value);
  }

  public function updateTextPrimitive(primitive:Dynamic, value:String) {
    (primitive:js.html.Text).textContent = value;
  }

  // @todo: Refactor this to be better  
  public function updatePrimitiveAttribute(primitive:Dynamic, name:String, value:Dynamic) {
    var el:Element = primitive;
    var isSvg = el.namespaceURI == svgNamespace;
    
    if (isHydrating) {
      // name = getHtmlName(name);
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
        // name = getHtmlName(name);
        // @todo: Setting events this way feels questionable.
        if (name.startsWith('on')) {
          var name = name.toLowerCase();
          if (value == null) {
            Reflect.setField(el, name, cast null);
          } else {
            Reflect.setField(el, name, value);
          }
        } else if (value == null || (value is Bool && value == false)) {
          el.removeAttribute(name);
        } else if (value is Bool && value == true) {
          el.setAttribute(name, name);
        } else {
          el.setAttribute(name, value);
        }
    }
  }

  // function getHtmlName(name:String) {
  //   if (name.startsWith('aria')) {
  //     return 'aria-' + name.substr(4).toLowerCase();
  //   }
  //   return name;
  // }

  public function insertPrimitive(primitive:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    if (isHydrating) return;
    var el:js.html.Element = primitive;
    if (slot != null && slot.previous != null) {
      var relative:js.html.Element = slot.previous;
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

    var relative:js.html.Element = to.previous;
    assert(relative != null);
    relative.after(el);
  }

  public function removePrimitive(primitive:Dynamic, slot:Null<Slot>) {
    (primitive:Element).remove();
  }
}
