package pine.html.client;

import js.Browser;
import pine.adaptor.*;
import pine.debug.Debug;
import pine.element.Slot;
import pine.hydration.Cursor;

using StringTools;
using pine.core.ObjectTools;
using pine.html.client.DomTools;

class ClientAdaptor extends Adaptor {
  final process = new ClientProcess();

  public function new() {}

  public function getProcess():Process {
    return process;
  }

  public function createCursor(object:Dynamic):Cursor {
    return new ClientCursor(object);
  }

  public function createPlaceholder():ObjectComponent {
    return new Text('');
  }

  public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent {
    return new ClientRoot({ el: target, child: child });
  }

  public function createObject(type:ObjectType, component:ObjectComponent):Dynamic {
    return switch type {
      case ObjectRoot:
        throw 'Cannot create a root object';
      case ObjectText | ObjectPlaceholder:
        return new js.html.Text(component.getObjectData());
      case ObjectElement(tag):
        var el = tag.startsWith('svg:')
          ? Browser.document.createElementNS(DomTools.svgNamespace, tag.substr(4)) 
          : Browser.document.createElement(tag);
        updateObject(type, el, component, null);
        return el;
    }
  }

  public function updateObject(type:ObjectType, object:Dynamic, component:ObjectComponent, previousComponent:Null<ObjectComponent>) {
    switch type {
      case ObjectRoot | ObjectPlaceholder:
        // noop
      case ObjectText:
        var text:js.html.Text = object;
        if (previousComponent == null || component.getObjectData() != previousComponent.getObjectData()) {
          var content:String = component.getObjectData();
          text.textContent = content == null ? '' : content;
        }
      case ObjectElement(_):
        var el:js.html.Element = object;
        var newAttrs = component.getObjectData();
        var oldAttrs = previousComponent != null ? previousComponent.getObjectData() : {};
        oldAttrs.diff(newAttrs, (key, oldValue, newValue) -> {
          el.updateNodeAttribute(key, oldValue, newValue);
        });
    }
  }

  public function insertObject(type:ObjectType, object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    switch type {
      case ObjectRoot:
      default:
        var el:js.html.Element = object;
        if (slot != null && slot.previous != null) {
          var relative:js.html.Element = slot.previous.getObject();
          relative.after(el);
        } else {
          var parent:js.html.Element = findParent();
          Debug.assert(parent != null);
          parent.prepend(el);
        }
    }
  }

  public function moveObject(type:ObjectType, object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    switch type {
      case ObjectRoot:
      default:
        var el:js.html.Element = object;

        if (to == null) {
          if (from != null) {
            removeObject(type, object, from);
          }
          return;
        }

        if (from != null && !from.indexChanged(to)) {
          return;
        }

        if (to.previous == null) {
          var parent:js.html.Element = findParent();
          Debug.assert(parent != null);
          parent.prepend(el);
          return;
        }

        var relative:js.html.Element = to.previous.getObject();
        Debug.assert(relative != null);
        relative.after(el);
    }
  }

  public function removeObject(type:ObjectType, object:Dynamic, slot:Null<Slot>) {
    switch type {
      case ObjectRoot:
      default:
        var el:js.html.Element = object;
        el.remove();
    }
  }
}
