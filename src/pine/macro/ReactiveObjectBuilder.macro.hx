package pine.macro;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

function build() {
  final builder = ClassBuilder.fromContext();
  final props:Array<FieldBuilder> = [];
  
  for (field in builder.getFields()) {
    if (
      field.meta.length == 0 
      && field.access.contains(AFinal)
      && !field.access.contains(AStatic)
    ) {
      props.push(createConstantField(field));
    }
  }

  for (field in builder.findFieldsByMeta(':constant')) {
    props.push(createConstantField(field));
  }
  
  for (field in builder.findFieldsByMeta(':signal')) {
    props.push(createSignalField(field, false));
  }
  
  for (field in builder.findFieldsByMeta(':observable')) {
    props.push(createSignalField(field, true));
  }

  var inits = props.map(p -> p.init);
  var props = props.map(p -> p.prop);
  var computed:Array<Expr> = [];
  var propType:ComplexType = TAnonymous(props);

  for (field in builder.findFieldsByMeta(':computed')) {
    computed.push(createComputed(field));
  }

  var computation:Expr = if (computed.length > 0) macro {
    var prevOwner = pine.signal.Graph.setCurrentOwner(Some(this));
    try $b{computed} catch (e) {
      pine.signal.Graph.setCurrentOwner(prevOwner);
      throw e;
    }
    pine.signal.Graph.setCurrentOwner(prevOwner);
  } else macro null;

  for (field in builder.findFieldsByMeta(':action')) switch field.kind {
    case FFun(f):
      if (f.ret != null && f.ret != macro:Void) {
        Context.error(':action methods cannot return anything', field.pos);
      }
      var expr = f.expr;
      f.expr = macro pine.signal.Action.run(() -> $expr);
    default:
      Context.error(':action fields must be functions', field.pos);
  }

  switch builder.findField('new') {
    case Some(field): switch field.kind {
      case FFun(f):
        var expr = f.expr;
        f.expr = macro {
          $expr;
          ${computation};
        }
      default:
        throw 'assert';
    }
    case None:
      builder.add(macro class {
        public function new(props:$propType) {
          $b{inits};
          ${computation};
        }
      });
  }

  return builder.export();
}

private typedef FieldBuilder = {
  public final name:String;
  public final init:Expr;
  public final prop:Field;
}

private function createConstantField(field:Field):FieldBuilder {
  return switch field.kind {
    case FVar(t, e):
      if (!field.access.contains(AFinal)) {
        Context.error('@:constant fields must be final', field.pos);
      }

      {
        name: field.name,
        init: createInit(field.name, e),
        prop: createProp(field.name, t, e != null, Context.currentPos())
      }
    default:
      Context.error('Invalid field', field.pos);
  }
}

private function createSignalField(field:Field, isReadonly:Bool):FieldBuilder {
  return switch field.kind {
    case FVar(t, e):
      if (!field.access.contains(AFinal)) {
        if (Compiler.getConfiguration().debug) {
          Context.warning(
            '@:signal and @:observable fields are strongly encouraged to be final. They will be converted to final fields by the compiler for you, which may be confusing.',
            field.pos
          );
        }
        field.access.push(AFinal);
      }

      var type = switch t {
        case macro:Null<$t>: isReadonly 
          ? macro:pine.signal.Signal.ReadonlySignal<Null<$t>>
          : macro:pine.signal.Signal<Null<$t>>;
        default: isReadonly 
          ? macro:pine.signal.Signal.ReadonlySignal<$t>
          : macro:pine.signal.Signal<$t>;
      }
      
      field.kind = FVar(type, switch e {
        case macro null if (isReadonly): macro new pine.signal.Signal.ReadonlySignal(null);
        case macro null: macro new pine.signal.Signal(null);
        default: e;
      });

      {
        name: field.name,
        init: createInit(field.name, e),
        prop: createProp(field.name, type, e != null, Context.currentPos())
      };
    default:
      Context.error('Invalid field', field.pos);
  }
}

private function createComputed(field:Field):Expr {
  return switch field.kind {
    case FVar(t, e):
      if (t == null) {
        Context.error('@:computed field require an explicit type', field.pos);
      }
      if (e == null) {
        Context.error('@:computed fields require an expression', field.pos);
      }
      if (!field.access.contains(AFinal)) {
        Context.error('@:computed fields must be final', field.pos);
      }

      field.kind = FVar(macro:pine.signal.Computation<$t>, null);
      var name = field.name;

      return macro this.$name = new pine.signal.Computation(() -> $e);
    default:
      Context.error('Invalid field', field.pos);
  }
}

private function createInit(name:String, e:Null<Expr>) {
  return if (e == null){
    macro this.$name = props.$name;
  } else {
    macro if (props.$name != null) this.$name = props.$name;
  }
}

private function createProp(name:String, type:ComplexType, isOptional:Bool, pos:Position):Field {
  return {
    name: name,
    pos: pos,
    meta: isOptional ? [{name: ':optional', pos: pos}] : [],
    kind: FVar(type, null)
  }
}