package pine.internal.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.internal.macro.ClassBuilder;

using Lambda;

function build() {
  final builder = ClassBuilder.fromContext();
  final props:Array<Field> = [];
  final inits:Array<Expr> = [];

  for (field in builder.getFields()) switch field.kind {
    case FVar(t, e) if (
      field.access.contains(AFinal)
      && !field.access.contains(AStatic)
      && !field.meta.exists(m -> m.name == ':skip')
    ):
      var name = field.name;
      var pos = Context.currentPos();
      props.push({
        name: name,
        pos: pos,
        meta: e != null ? [{name: ':optional', pos: pos}] : [],
        kind: FVar(t, null)
      });
      inits.push(e == null ? macro this.$name = props.$name : macro if (props.$name != null) this.$name = props.$name);
    case FVar(t, e) if (
      !field.access.contains(AFinal)
      && !field.access.contains(AStatic)
      && !field.meta.exists(m -> m.name == ':skip')
    ):
      var name = field.name;
      var pos = Context.currentPos();
      field.access.push(AFinal);
      field.kind = FVar(macro:pine.signal.Signal<$t>, e);
      props.push({
        name: name,
        pos: pos,
        meta: e != null ? [{name: ':optional', pos: pos}] : [],
        kind: FVar(macro:pine.signal.Signal<$t>, null)
      });
      inits.push(e == null ? macro this.$name = props.$name : macro if (props.$name != null) this.$name = props.$name);
    default:
  }

  final type:ComplexType = TAnonymous(props);

  builder.add(macro class {
    public function new(props:$type) {
      $b{inits};
    }
  });

  return builder.export();
}
