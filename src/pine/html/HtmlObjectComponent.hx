package pine.html;

import pine.Children;
import pine.signal.Signal;
import pine.ObjectComponent;

// @todo: This can probably be merged with ElementComponent. 
class HtmlObjectComponent<Attrs:{} & { ?children:Children }> extends ElementWithChildrenComponent {
  final tag:String;
  final attrs:Attributes;
  final children:Children;

  public function new(tag:String, props:Attrs) {
    this.tag = tag;
    this.children = props.children ?? new ReadonlySignal([]);
    this.attrs = new Attributes([]);
    for (field in Reflect.fields(props)) {
      if (field == 'children') continue;
      var value:pine.html.HtmlAttribute<Any> = Reflect.field(props, field);
      this.attrs.set(field, switch value?.unwrap() {
        case null: new ReadonlySignal(null);
        case Left(v): new ReadonlySignal(v);
        case Right(signal): signal;
      });
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

class HtmlVoidObjectComponent<Attrs:{}> extends ElementWithoutChildrenComponent {
  final tag:String;
  final attrs:Attributes;
  
  public function new(tag:String, props:Attrs) {
    this.tag = tag;
    this.attrs = new Attributes([]);
    for (field in Reflect.fields(props)) {
      var value:pine.html.HtmlAttribute<Any> = Reflect.field(props, field);
      this.attrs.set(field, switch value.unwrap() {
        case Left(v): new ReadonlySignal(v);
        case Right(signal): signal;
      });
    }
  }

  public function getName() {
    return tag;
  }

  public function getAttributes() {
    return attrs;
  }
}