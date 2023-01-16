package pine.html.server;

import pine.adaptor.*;
import pine.debug.Debug;
import pine.element.Slot;
import pine.object.Object;

class ServerAdaptor extends Adaptor {
  final process = new ServerProcess();

  public function new() {}  

  public function getProcess():Process {
    return process;
  }

  public function createPlaceholder():ObjectComponent {
    return new HtmlTextComponent({ content: '' });
  }

  public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent {
    return new ServerRoot({ el: target, child: child });
  }

  public function createObject(type:ObjectType, component:ObjectComponent):Dynamic {
    return switch type {
      case ObjectRoot: 
        throw 'Cannot create a root object';
      case ObjectText:
        return new HtmlTextObject(component.getObjectData());
      case ObjectElement(tag):
        return new HtmlElementObject(tag, component.getObjectData());
      case ObjectPlaceholder:
        return new HtmlTextObject('');
    }
  }

  public function updateObject(type:ObjectType, object:Dynamic, component:ObjectComponent, previousComponent:Null<ObjectComponent>) {
    switch type {
      case ObjectRoot | ObjectPlaceholder:
        // noop
      case ObjectText:
        var text:HtmlTextObject = object;
        text.updateContent(component.getObjectData());
      case ObjectElement(_):
        var el:HtmlElementObject = object;
        el.updateAttributes(component.getObjectData());
    }
  }

  public function insertObject(type:ObjectType, object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    switch type {
      case ObjectRoot:
        // Noop
      default:
        var obj:Object = object;
        if (slot != null && slot.previous != null) {
          var relative:Object = slot.previous.getObject();
          var parent = relative.parent;
          if (parent != null) {
            var index = parent.children.indexOf(relative);
            parent.insert(index + 1, obj);
          } else {
            var parent:Object = findParent();
            Debug.assert(parent != null);
            parent.prepend(obj);
          }
        } else {
          var parent:Object = findParent();
          Debug.assert(parent != null);
          parent.prepend(obj);
        }
    }
  }

  public function moveObject(type:ObjectType, object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    switch type {
      case ObjectRoot:
        // noop
      default:
        var obj:Object = object;
        Debug.alwaysAssert(to != null);

        if (from != null && !from.indexChanged(to)) {
          return;
        }

        if (to.previous == null) {
          var parent:Object = findParent();
          Debug.assert(parent != null);
          parent.prepend(object);
          return;
        }

        var relative:Object = to.previous.getObject();
        var parent = relative.parent;

        Debug.alwaysAssert(parent != null);

        var index = parent.children.indexOf(relative);

        parent.insert(index + 1, obj);
    }
  }

  public function removeObject(type:ObjectType, object:Dynamic, slot:Null<Slot>) {
    switch type {
      case ObjectRoot:
        // noop
      default:
        var obj:Object = object;
        obj.remove();
    }
  }
}
