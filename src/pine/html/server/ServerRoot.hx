package pine.html.server;

import pine.render.Object;
import pine.render.ObjectRootElement;

class ServerRoot extends RootComponent {
  static final type = new UniqueId();

  final el:Object;

  public function new(props:{
    el:Object,
    child:Component
  }) {
    super(props);
    this.el = props.el;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function createElement():Element {
    return new ServerRootElement(this);
  }

  public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    return object;
  }

  public function getRootObject():Dynamic {
    return el;
  }
}

class ServerRootElement extends ObjectRootElement implements HtmlRoot {
  public function createPlaceholderObject(component:Component):Dynamic {
    return new HtmlTextObject('');
  }

  public function createHtmlElement<Attrs:{}>(tag:String, attrs:Attrs, isSvg:Bool):Dynamic {
    return new HtmlElementObject(tag, attrs);
  }

  public function updateHtmlElement<Attrs:{}>(object:Dynamic, newAttrs:Attrs, ?oldAttrs:Attrs) {
    var el:HtmlElementObject = object;
    el.updateAttributes(newAttrs);
  }

  public function createHtmlText(content:String):Dynamic {
    return new HtmlTextObject(content);
  }

  public function updateHtmlText(object:Dynamic, content:String, ?previous:String) {
    var text:HtmlTextObject = object;
    text.updateContent(content);
  }
}
