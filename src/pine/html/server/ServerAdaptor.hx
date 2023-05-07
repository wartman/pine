package pine.html.server;

import pine.debug.Debug;
import pine.internal.*;
import pine.object.*;
import pine.internal.Slot;

typedef ServerAdaptorOptions = {
  ?prefixTextWithMarker:Bool
};

class ServerAdaptor implements Adaptor {
  final options:ServerAdaptorOptions;

  public function new(?options) {
    this.options = options ?? { prefixTextWithMarker: true };
  }

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
    return new HtmlElementObject(name, initialAttrs);
  }

  public function createTextObject(value:String):Dynamic {
    return new HtmlTextObject(value, options?.prefixTextWithMarker ?? true);
  }

  public function createPlaceholderObject():Dynamic {
    return new HtmlPlaceholderObject();
  }

  public function createCursor(object:Dynamic):Cursor {
    return new ObjectCursor(object);
  }

  public function updateTextObject(object:Dynamic, value:String) {
    (object:HtmlTextObject).updateContent(value);
  }

  public function updateObjectAttribute(object:Dynamic, name:String, value:Dynamic, ?isHydrating:Bool) {
    (object:HtmlElementObject).setAttribute(name, value);
  }

  public function insertObject(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    var obj:Object = object;
    if (slot != null && slot.previous != null) {
      var relative:Object = slot.previous.getObject();
      var parent = relative.parent;
      if (parent != null) {
        var index = parent.children.indexOf(relative);
        parent.insert(index + 1, obj);
      } else {
        var parent:Object = findParent();
        assert(parent != null);
        parent.prepend(obj);
      }
    } else {
      var parent:Object = findParent();
      assert(parent != null);
      parent.prepend(obj);
    }
  }

  public function moveObject(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    var obj:Object = object;
    assert(to != null);

    if (from != null && !from.indexChanged(to)) {
      return;
    }

    if (to.previous == null) {
      var parent:Object = findParent();
      assert(parent != null);
      parent.prepend(object);
      return;
    }

    var relative:Object = to.previous.getObject();
    var parent = relative.parent;

    assert(parent != null);

    var index = parent.children.indexOf(relative);

    parent.insert(index + 1, obj);
  }

  public function removeObject(object:Dynamic, slot:Null<Slot>) {
    var obj:Object = object;
    obj.remove();
  }
}