package pine.html;

import pine.internal.Debug;
import pine.Children;
import pine.signal.Signal;
import pine.ObjectComponent;

// @todo: This can probably be merged with ElementComponent. 
class HtmlObjectComponent<Attrs:{} & { ?children:Children }> extends ObjectWithChildrenComponent {
  final tag:String;
  final attrs:Attributes;
  final children:Children;

  public function new(tag:String, props:Attrs) {
    this.tag = tag;
    this.children = props.children ?? new ReadonlySignal([]);
    this.attrs = new Attributes([]);
    for (field in Reflect.fields(props)) {
      if (field == 'children') continue;
      this.attrs.set(field, Reflect.field(props, field));
    }
  }

  public function getName() {
    return tag;
  }

  public function getAttributes() {
    return attrs;
  }

  public function getChildren() {
    return children;
  }
}

class HtmlVoidObjectComponent<Attrs:{}> extends ObjectWithoutChildrenComponent {
  final tag:String;
  final attrs:Attributes;
  
  public function new(tag:String, props:Attrs) {
    this.tag = tag;
    this.attrs = new Attributes([]);
    for (field in Reflect.fields(props)) {
      this.attrs.set(field, Reflect.field(props, field));
    }
  }

  public function getName() {
    return tag;
  }

  public function getAttributes() {
    return attrs;
  }
}