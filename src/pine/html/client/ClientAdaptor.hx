package pine.html.client;

import js.Browser;
import js.html.Element;
import js.html.Node;
import pine.Constants;
import pine.debug.Debug;
import pine.html.HtmlEvents.EventListener;

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

  public function createContainerPrimitive(slot:Slot, findParent:()->Dynamic):Dynamic {
    return createPrimitive('div', slot, findParent);
  }

  public function createPrimitive(name:String, slot:Slot, findParent:()->Dynamic):Dynamic {
    if (isHydrating) {
      var primitive:Node = hydrateNearestPrimitive(slot, findParent);
      assert({
        var tag = name.startsWith('svg:') ? name.substr(4) : name;
        primitive != null && primitive.nodeName.toLowerCase() == tag;
      }, 'Hydration failed: expected a ${name} node');
      return primitive;
    }
    return name.startsWith('svg:')
      ? Browser.document.createElementNS(svgNamespace, name.substr(4)) 
      : Browser.document.createElement(name);
  }

  public function createTextPrimitive(value:String, slot:Slot, findParent:()->Dynamic):Dynamic {
    if (isHydrating) {
      var primitive:Node = hydrateNearestPrimitive(slot, findParent);
      assert(primitive != null && primitive.nodeType == Node.TEXT_NODE, 'Hydration failed: expected a Text node');
      return primitive;
    }
    return Browser.document.createTextNode(value);
  }

  public function createPlaceholderPrimitive(slot:Slot, findParent:()->Dynamic):Dynamic {
    if (isHydrating) {
      var primitive:Node = hydrateNearestPrimitive(slot, findParent);
      assert(primitive != null && primitive.nodeType == Node.COMMENT_NODE, 'Hydration failed: expected a placeholder node.');
      return primitive;
    }
    return Browser.document.createComment('<!--${PlaceholderMarker}-->');
  }

  public function updateTextPrimitive(primitive:Dynamic, value:String) {
    (primitive:js.html.Text).textContent = value;
  }

  public function updatePrimitiveAttribute(primitive:Dynamic, name:String, value:Dynamic) {
    var el:Element = primitive;
    var isSvg = el.namespaceURI == svgNamespace;
    var namespace = isSvg ? svgNamespace : null;

    switch name {
      case 'xmlns' if (isSvg): // skip
      case 'value' | 'selected' | 'checked' if (!isSvg && !isHydrating):
        js.Syntax.code('{0}[{1}] = {2}', el, name, value);
      case _ if (name.startsWith('on')):
        updateEventListener(el, name, value);
      case _ if (
        !isSvg 
        && !isHydrating
        && value != null 
        && js.Syntax.code('{0} in {1}', name, el)
      ):
        // @todo: Not sure if this is the best idea for setting props.
        js.Syntax.code('{0}[{1}] = {2}', el, name, value);
      default:
        setAttribute(el, name, value, namespace);
    }
  }

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

  function setAttribute(element:Element, name:String, ?value:Dynamic, ?namespace:String) {
    if (isHydrating) return;

    var shouldRemove = value == null || (value is Bool && value == false);

    if (shouldRemove) return if (namespace != null) {
      element.removeAttributeNS(namespace, name);
    } else {
      element.removeAttribute(name);
    }

    if (value is Bool && value == true) value = name;

    switch name {
      case 'class' | 'className': 
        updateClassList(element, value);
      case 'dataset': 
        updateDataset(element, value);
      default:
        if (namespace != null) {
          element.setAttributeNS(namespace, name, value);
        } else {
          element.setAttribute(name, value);
        }
    }
  }

  function updateClassList(element:Element, value:String) {
    if (isHydrating) return;

    var oldValue = element.classList.value;
    var oldNames = Std.string(oldValue ?? '').split(' ').filter(n -> n != null && n != '');
    var newNames = Std.string(value ?? '').split(' ').filter(n -> n != null && n != '');

    for (name in oldNames) {
      if (!newNames.contains(name)) {
        element.classList.remove(name);
      } else {
        newNames.remove(name);
      }
    }

    if (newNames.length > 0) {
      element.classList.add(...newNames);
    }
  }

  function updateDataset(element:Element, map:Map<String, String>) {
    if (isHydrating) return;

    for (key => value in map) {
      if (value == null) {
        Reflect.deleteField(element.dataset, key);  
      } else {
        Reflect.setField(element.dataset, key, value);
      }
    }
  }

  function updateEventListener(element:Element, name:String, ?handler:EventListener) {
    // @todo: Look into delegation?

    // @todo: We're not actually using `addEventListener` here as we
    // don't currently have things set up to remove old ones.
    // Instead, we're setting properties. This seems a bit questionable
    // as a concept, so it's just a short-term solution.
    var name = name.toLowerCase();
    if (handler == null) {
      Reflect.setField(element, name, cast null);
    } else {
      Reflect.setField(element, name, handler);
    }
  }

  function hydrateNearestPrimitive(slot:Slot, findParent:()->Dynamic):Dynamic {
    var prev:Null<Node> = slot.previous;
    if (prev == null) {
      return skipComments((findParent():Node).firstChild);
    }
    return skipComments(prev.nextSibling);
  }

  function skipComments(node:Null<Node>) {
    if (node == null) return null;
    if (node.nodeType == Node.COMMENT_NODE) {
      if (node.textContent == PlaceholderMarker) return node;
      return skipComments(node.nextSibling);
    }
    return node;
  }
}
