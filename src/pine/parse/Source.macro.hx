package pine.parse;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

typedef SourceData = {
  public final content:String;
  public final file:String;
  public final offset:Int;
}

@:forward
abstract Source(SourceData) {
  @:from public static function ofExpr(e:Expr) {
    var offset = 1;
    var expr = switch e {
      case macro @:markup $value: 
        offset = 0;
        switch value.expr {
          case EDisplay(e, _): e; // this is a thing apparently
          case _: value;
        }
      default: e;
    }
    var content = switch expr.expr {
      case EConst(CString(s, _)): s;
      default: Context.error('Expected a string or markup literal', e.pos);
    }
    var pos = e.pos.getInfos();

    return new Source({
      content: content,
      file: pos.file,
      offset: pos.min + offset
    });
  }

  public function new(data) {
    this = data;
  }
}
