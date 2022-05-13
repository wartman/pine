package pine.html.dom;

import js.Browser;
import pine.html.shared.ObjectTools;

class DomRoot extends RootComponent {
  static final type = new UniqueId();

  final el:js.html.Element;

  public function new(props:{
    el:js.html.Element,
    child:Component,
    ?scheduler:Scheduler
  }) {
    super(props);
    this.el = props.el;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function getRootObject():Dynamic {
    return el;
  }

  public function createElement():Element {
    return new DomRootElement(this);
  }
}

class DomRootElement extends RootElement implements HtmlRoot {
  public function createHtmlElement<Attrs:{}>(tag:String, attrs:Attrs, isSvg:Bool):Dynamic {
    var el = isSvg ? Browser.document.createElementNS(DomTools.svgNamespace, tag) : Browser.document.createElement(tag);
    updateHtmlElement(el, attrs);
    return el;
  }

  public function updateHtmlElement<Attrs:{}>(object:Dynamic, newAttrs:Attrs, ?oldAttrs:Attrs) {
    var el:js.html.Element = object;
    if (oldAttrs == null) {
      oldAttrs = cast {};
    }
    ObjectTools.diffObject(oldAttrs, newAttrs, DomTools.updateNodeAttribute.bind(el));
  }

  public function createHtmlText(content:String):Dynamic {
    return new js.html.Text(content);
  }

  public function updateHtmlText(object:Dynamic, content:String, ?previous:String):Void {
    var text:js.html.Text = object;
    if (previous != null && content != previous) {
      text.textContent = content == null ? '' : content;
    }
  }

  public function insertObject(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
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
      Debug.assert(parent != null);
      parent.prepend(el);
      return;
    }

    var relative:js.html.Element = to.previous.getObject();
    Debug.assert(relative != null);
    relative.after(el);
  }

  public function removeObject(object:Dynamic, slot:Null<Slot>) {
    var el:js.html.Element = object;
    el.remove();
  }

  public function createPlaceholderObject(component:Component):Dynamic {
    return createHtmlText('');
  }
}
