package pine.html.server;

import pine.internal.Cursor;
import kit.Assert;

import pine.internal.Adaptor;
import pine.object.*;

class ServerAdaptor implements Adaptor {
  public function new() {}

  public function createElementObject(name:String, initialAttrs:{}):Dynamic {
    return new HtmlElementObject(name, initialAttrs);
  }

  public function createTextObject(value:String):Dynamic {
    return new HtmlTextObject(value);
  }

  public function createPlaceholderObject():Dynamic {
    return new HtmlTextObject('');
  }

  public function createCursor(object:Dynamic):Cursor {
    return new ObjectCursor(object);
  }

  public function updateTextObject(object:Dynamic, value:String) {
    (object:HtmlTextObject).updateContent(value);
  }

  public function updateObjectAttribute(object:Dynamic, name:String, value:Dynamic) {
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