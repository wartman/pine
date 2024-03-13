package pine.html.server;

import pine.debug.Debug;

using StringTools;

class ServerAdaptor implements Adaptor {
  public function new() {}

  public function hydrate(scope:() -> Void) {
    scope();
  }

  public function createContainerPrimitive(slot:Slot, findParent:() -> Dynamic):Dynamic {
    return createPrimitive('div', slot, findParent);
  }

  public function createPrimitive(name:String, slot:Slot, findParent:() -> Dynamic):Dynamic {
    if (name.startsWith('svg:')) name = name.substr(4);
		return new ElementPrimitive(name, {});
  }

  public function createTextPrimitive(text:String, slot:Slot, findParent:() -> Dynamic):Dynamic {
    return new TextPrimitive('');
  }

  public function createPlaceholderPrimitive(slot:Slot, findParent:()->Dynamic):Dynamic {
    return new PlaceholderPrimitive();
  }

  public function updateTextPrimitive(primitive:Dynamic, value:String) {
    (primitive:TextPrimitive).updateContent(value);
  }

  public function updatePrimitiveAttribute(primitive:Dynamic, name:String, value:Dynamic) {
    var el:ElementPrimitive = primitive;
    switch name {
      case 'className' | 'class':
        var oldValue = el.classList.join(' ');
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
          for (name in newNames) el.classList.add(name);
        }
      default:
        el.setAttribute(name, value);
    }
  }

  public function insertPrimitive(primitive:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    var node:Primitive = primitive;
    if (slot != null && slot.previous != null) {
      var relative:Primitive = slot.previous;
      var parent = relative.parent;
      if (parent != null) {
        var index = parent.children.indexOf(relative);
        parent.insert(index + 1, node);
      } else {
        var parent:Primitive = findParent();
        assert(parent != null);
        parent.prepend(node);
      }
    } else {
      var parent:Primitive = findParent();
      assert(parent != null);
      parent.prepend(node);
    }
  }

  public function movePrimitive(primitive:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    var node:Primitive = primitive;
    assert(to != null);

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
      var parent:Primitive = findParent();
      assert(parent != null);
      parent.prepend(node);
      return;
    }

    var relative:Primitive = to.previous;
    var parent = relative.parent;

    assert(parent != null);

    var index = parent.children.indexOf(relative);

    parent.insert(index + 1, node);
  }

  public function removePrimitive(primitive:Dynamic, slot:Null<Slot>) {
    (primitive:Primitive).remove();
  }
}
