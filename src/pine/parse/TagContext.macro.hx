package pine.parse;

import pine.parse.Tag;
import haxe.macro.Context;

using Lambda;
using pine.parse.ParseTools;

class TagContext {
  final tags:Map<String, Tag> = [];
  final primitives:Array<String>;

  var primitivesLoaded:Bool = false;

  public function new(primitives) {
    this.primitives = primitives;
  }

  function getPrimitives() {
    return primitives;
  }

  public function resolve(name:Located<String>):Tag {
    return switch tags.get(name.value) {
      case null: 
        switch Context.getLocalTVars().get(name.value) {
          case null if (name.value.isComponentName()):
            var type = Context.typeof(macro @:pos(name.pos) $p{name.value.toPath()});
            tags[name.value] = Tag.fromType(name, type);
          case null:
            loadPrimitiveTags();
            if (tags.exists(name.value)) {
              return tags.get(name.value);
            }
            Context.error('Unknown tag: <${name.value}>', name.pos);
          case type:
            tags[name.value] = Tag.fromType(name, type.t);
        }
      case tag:
        tag;
    }
  }

  function loadPrimitiveTags() {
    if (primitivesLoaded) return;
    primitivesLoaded = true;

    for (typeName in primitives) {
      var type = Context.getType(typeName);
      var fields = switch type {
        case TType(t, _): switch t.get().type {
          case TAnonymous(a): a.get().fields;
          default: throw 'assert';
        }
        default: throw 'assert';
      }
      for (f in fields) {
        tags[f.name] = Tag.fromType({
          value: f.name,
          pos: f.pos
        }, f.type, FromPrimitive);
      }
    }
  }
}
