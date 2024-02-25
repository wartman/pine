package pine.bridge;

import haxe.macro.Context;

class IslandAsset {  
  static function getCurrentClassPaths() {
    var paths = Context.getClassPath();
    var exprs = [ for (path in paths) macro $v{path} ];
    return macro [ $a{exprs} ];
  }
}