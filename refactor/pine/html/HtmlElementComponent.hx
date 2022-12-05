package pine.html;

import pine.element.*;
import pine.diffing.Key;
import pine.element.object.DirectChildrenManager;
#if debug
import pine.debug.Debug;
#end

abstract class HtmlElementComponent<Attrs:{}> extends ObjectComponent {
  public final tag:String;
  public final attrs:Attrs;
  public final isSvg:Bool;
  public final children:Null<Array<Component>>;

  public function new(props:{
    tag:String,
    attrs:Attrs,
    ?isSvg:Bool,
    ?children:Array<Component>,
    ?key:Key
  }) {
    super(props.key);
    tag = props.tag;
    attrs = props.attrs;
    isSvg = props.isSvg == null ? false : props.isSvg;
    children = props.children;
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new DirectChildrenManager(element, context -> {
      var component:HtmlElementComponent<Attrs> = context.getComponent();
      var children = component.children;
      if (children == null) return [];
      return children;
    });
  }

  #if debug
  // override function createHooks():HookCollection<Dynamic> {
  //   return new HookCollection<HtmlElementComponent<Attrs>>([
  //     element -> element.watchLifecycle({
  //       beforeHydrate: (element, cursor) -> {
  //         // // @todo: We need a cross-platform way to get the tag
  //         // Debug.assert(element.component.tag == cursor.current());
  //       }
  //     })
  //   ]);
  // }
  #end
}
