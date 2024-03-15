package pine.bridge;

import haxe.Json;

using Reflect;
using StringTools;

class IslandElement extends Component {
  public static inline extern final tag:String = 'pine-island';
  
  #if pine.client
  @:noUsing public static function getIslandElementsForComponent(name:String) {
    var items = js.Browser.document.querySelectorAll('$tag[data-component="$name"]');
    return [ for (i in 0...items.length) items.item(i).as(js.html.Element) ];
  }

  public static function getIslandProps(el:js.html.Element):{} {
    var raw = el.getAttribute('data-props') ?? '';
    return haxe.Json.parse(raw.htmlUnescape());
  }

  static function getIslandElements():Array<js.html.Element> {
    var items = js.Browser.document.querySelectorAll(tag);
    return [ for (i in 0...items.length) items.item(i).as(js.html.Element) ];
  }
  #else
  @:noUsing public static function getIslandElementsForComponent(name:String) {
    return [];
  }
  #end

  @:attribute final component:String;
  @:attribute final props:{};
  @:children @:attribute final child:Child;

  function render():Child {
    #if pine.client
    return child;
    #else
    getContext(IslandContext)?.registerIsland(component);
    return new PrimitiveView(tag, [
      'data-component' => component,
      'data-props' => Json.stringify(props).htmlEscape(true)
    ], child);
    #end
  }
}
