package pine.html;

import pine.Disposable;
import pine.html.HtmlEvents;
import pine.signal.Graph;
import pine.signal.Observer;
import pine.signal.Signal;

using Lambda;

// @todo: Add an efficient template-based solution we can
// use with macro-parsed xml. See what Solid is doing. 

class Html implements ViewBuilder {
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
  
  public function attr(name:String, value:ReadOnlySignal<Dynamic>) {
    // @todo: Something better than this:
    if (attributes.exists(name) && name == 'class') {
      var prev = attributes.get(name);
      attributes.set(name, prev.map(prev -> prev + ' ' + value()));
      return this;
    }

    attributes.set(name, value);
    return this;
  }

  public function on(event:String, value:ReadOnlySignal<EventListener>) {
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
    return new HtmlView(
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

class HtmlView extends View {
  final primitive:Dynamic;
  final disposables:DisposableCollection = new DisposableCollection();
  final attributes:Map<String, ReadOnlySignal<Dynamic>> = [];
  final children:Array<View>;
  
  public function new(
    parent, 
    adaptor,
    slot,
    tag,
    attributes,
    children:Array<ViewBuilder>,
    ref:Null<(primitive:Dynamic)->Void>
  ) {
    super(parent, adaptor, slot);
    
    this.primitive = adaptor.createPrimitive(tag);
    this.attributes = attributes;
    this.children = [];
  
    var previousOwner = setCurrentOwner(Some(disposables));

    for (name => value in attributes) Observer.track(() -> {
      adaptor.updatePrimitiveAttribute(primitive, name, value());
    });
    
    var previous:Null<View> = null;
    for (index => child in children) {
      var childView = child.createView(this, new Slot(index, previous?.getPrimitive()));
      this.children.push(childView);
      previous = childView;
    }

    setCurrentOwner(previousOwner);

    if (ref != null) ref(primitive);

    adaptor.insertPrimitive(primitive, slot, parent.findNearestPrimitive);
  }

  public function getSlot() {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {
    var prevSlot = this.slot;
    this.slot = slot;
    adaptor.movePrimitive(primitive, prevSlot, slot, parent.findNearestPrimitive);
  }

  public function findNearestPrimitive():Dynamic {
    return primitive;
  }

  public function getPrimitive():Dynamic {
    return primitive;
  }

  public function dispose() {
    adaptor.removePrimitive(primitive, slot);
    disposables.dispose();
    for (child in children) child.dispose();
  }
}
