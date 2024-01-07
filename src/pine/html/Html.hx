package pine.html;

import pine.Primitive;
import pine.html.HtmlEvents;
import pine.signal.Signal;

using Lambda;

class Html implements ViewBuilder {
  public macro static function template(e);

  public static inline function build(tag:String) {
    return new Html(tag);
  }

  final tag:String;
  final attributes:Map<String, ReadOnlySignal<Dynamic>> = [];
  
  var views:Array<ViewBuilder> = [];
  var refCallback:Null<(primitive:Dynamic)->Void> = null;

  public function new(tag) {
    this.tag = tag;
  }
  
  public function attr(name:HtmlAttributeName, value:ReadOnlySignal<Dynamic>) {
    // @todo: Something better than this:
    if (attributes.exists(name) && name == 'class') {
      var prev = attributes.get(name);
      attributes.set(name, prev.map(prev -> prev + ' ' + value()));
      return this;
    }

    attributes.set(name, value);
    return this;
  }

  public function on(event:HtmlEventName, value:ReadOnlySignal<EventListener>) {
    attributes.set('on' + event, value);
    return this;
  }

  public function ref(cb) {
    refCallback = cb;
    return this;
  }

  public function children(...views:Children) {
    this.views = this.views.concat(views.toArray().flatten());
    return this; 
  }

  public function createView(parent:View, slot:Null<Slot>):View {
    return new PrimitiveView(
      parent,
      parent.adaptor,
      slot,
      tag,
      attributes,
      views,
      refCallback
    );
  }
}

@:build(pine.html.Html.buildAttributeEnum())
enum abstract HtmlAttributeName(String) from String to String {}

@:build(pine.html.Html.buildEventEnum())
enum abstract HtmlEventName(String) to String {}

