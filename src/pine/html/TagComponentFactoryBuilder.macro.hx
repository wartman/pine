package pine.html;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;
import pine.macro.ClassBuilder;

using Lambda;
using haxe.macro.Tools;
using pine.macro.MacroTools;

private enum abstract TagKind(String) to String {
  var TagVoid = 'void';
  var TagNormal = 'normal';
  var TagOpaque = 'opaque';
}

private typedef TagInfo = {
  name:String,
  kind:TagKind,
  type:Type,
  element:Type
}

@:persistent private final taginfos:Map<String, Array<TagInfo>> = [];

function buildGeneric(tags:String, isSvg:Bool = false) {
  var infos = getTags(tags);
  return switch Context.getLocalType() {
    case TInst(cls, [TInst(_.get() => {kind: KExpr(macro $v{(tag:String)})}, _)]):
      var baseName = cls.get().name;
      var info = infos.find(i -> i.name == tag);
      if (info == null) {
        Context.error('Invalid tag name: ${tag}', Context.currentPos());
      }
      return buildComponent(baseName, info, isSvg);
    case TInst(cls, []):
      Context.error('Tag required', Context.currentPos());
      return null;
    default:
      throw 'assert';
  }
}

private function buildComponent(baseName:String, tag:TagInfo, isSvg:Bool) {
  var pack = ['pine', 'html'];
  var name = '${baseName}_${tag.name}';
  var path:TypePath = { pack: pack, name: name };

  if (!path.typePathExists()) {
    var builder = new ClassBuilder([]);
    var pos = Context.currentPos();
    var props = tag.type.toComplexType();

    builder.add(macro class {
      static final type:pine.UniqueId = pine.html.TagTypes.getTypeForTag($v{tag.name});
      
      public function getComponentType() {
        return type;
      }
    });

    var attrs = switch tag.kind {
      case TagNormal:
        var attrs = macro:$props & pine.html.HtmlEvents & { ?children:pine.html.HtmlChildren, ?key:pine.Key};
        builder.add(macro class {
          public function new(props:$attrs) {
            var children = props.children == null ? [] : props.children;
            var key = props.key;

            Reflect.deleteField(props, 'children');
            Reflect.deleteField(props, 'key');
            
            super({
              tag: $v{tag.name},
              attrs: props,
              key: key,
              children: children,
              isSvg: $v{isSvg}
            });
          }
        });
        attrs;
      default:
        var attrs = macro:$props & pine.html.HtmlEvents & { ?key:pine.Key};
        builder.add(macro class {
          public function new(props:$attrs) {
            super({
              tag: $v{tag.name},
              attrs: props,
              key: props.key,
              isSvg: $v{isSvg}
            });
          }
        });
        attrs;
    }

    Context.defineType({
      pack: pack,
      name: name,
      pos: pos,
      kind: TDClass({
        pack: pack,
        name: 'HtmlElementComponent',
        params: [ TPType(attrs) ]
      }),
      fields: builder.export()
    });
  }

  return TPath(path);
}

private function getTags(typeName:String):Array<TagInfo> {
  if (taginfos.exists(typeName)) return taginfos.get(typeName);

  var type = Context.getType(typeName);
  var tags:Array<TagInfo> = [];
  var groups = switch type {
    case TType(t, params): switch (t.get().type) {
        case TAnonymous(a): a.get().fields;
        default: throw 'assert';
      }
    default:
      throw 'assert';
  }

  for (group in groups) {
    var kind:TagKind = cast group.name;
    var fields = switch group.type {
      case TAnonymous(a): a.get().fields;
      default: throw 'assert';
    }
    for (f in fields) {
      var element = switch f.meta.extract(':element') {
        case []: 
          switch f.type {
            case TType(_.get() => {module: 'pine.html.HtmlAttributes', name: name}, params):
              var prefix = switch name.split('Attr') {
                case ['Global', '']: '';
                case [name, '']: name;
                default: throw 'assert';
              }
              Context.getType('js.html.${prefix}Element');
            default: throw 'assert';
          }
        case [{params: [path]}]:
          Context.getType(path.toString());
        default:
          Context.error('Invalid @:element', f.pos);
          throw 'assert';
      }
      tags.push({
        name: f.name,
        type: f.type,
        kind: kind,
        element: element
      });
    }
  }

  taginfos.set(typeName, tags);

  return tags;
}