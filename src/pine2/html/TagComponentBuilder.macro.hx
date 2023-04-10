package pine2.html;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;
import pine2.internal.macro.ClassBuilder;

using Lambda;
using haxe.macro.Tools;
using pine2.internal.macro.MacroTools;

function buildGeneric(typeName:String, isSvg:Bool = false) {
  return switch Context.getLocalType() {
    case TInst(cls, [ TInst(_.get() => {kind: KExpr(macro $v{(tag:String)})}, _) ]):
      buildComponent(cls.get().name, getTagInfo(tag, typeName), isSvg);
    case TInst(cls, [ TInst(t, params) ]):
      trace(t);
      throw 'assert';
    case TInst(cls, []):
      Context.error('Tag required', Context.currentPos());
      return null;
    default:
      throw 'assert';
  }
}

private function buildComponent(baseName:String, tag:TagInfo, isSvg:Bool):ComplexType {
  var pack = ['pine2', 'html'];
  var name = '${baseName}_${tag.name}';
  var path:TypePath = { pack: pack, name: name };
  
  if (path.typePathExists()) return TPath(path);

  var builder = new ClassBuilder([]);
  var pos = Context.currentPos();
  var props = tag.type.toComplexType();

  switch tag.kind {
    case TagNormal:
      var attrs = macro:$props & pine2.html.HtmlEvents & { 
        ?children:pine2.Children 
      };
      builder.add(macro class {
        public function new(attrs:$attrs) {
          super($v{tag.name}, attrs);
        }
      });
      Context.defineType({
        pack: pack,
        name: name,
        pos: pos,
        kind: TDClass({
          pack: [ 'pine2', 'html' ],
          name: 'HtmlObjectComponent',
          params: [ TPType(attrs) ]
        }),
        fields: builder.export()
      });
    default:
      var attrs = macro:$props & pine2.html.HtmlEvents;
      builder.add(macro class {
        public function new(attrs:$attrs) {
          super($v{tag.name}, attrs);
        }
      });
      Context.defineType({
        pack: pack,
        name: name,
        pos: pos,
        kind: TDClass({
          pack: [ 'pine2', 'html' ],
          name: 'HtmlObjectComponent',
          sub: 'HtmlVoidObjectComponent',
          params: [ TPType(attrs) ]
        }),
        fields: builder.export()
      });
  }

  return TPath(path);
}

private enum abstract TagKind(String) to String {
  var TagVoid = 'void';
  var TagNormal = 'normal';
  var TagOpaque = 'opaque';
}

private typedef TagInfo = {
  name:String,
  kind:TagKind,
  type:Type,
  element:ComplexType
}

@:persistent private final taginfos:Map<String, Array<TagInfo>> = [];

private function getTagInfo(tag:String, typeName:String):TagInfo {
  var infos = getTags(typeName);
  var info = infos.find(i -> i.name == tag);
  if (info == null) {
    Context.error('Invalid tag name: ${tag}', Context.currentPos());
  }
  return info;
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
      var element = if (Context.defined('js') && !Context.defined('nodejs')) 
        switch f.meta.extract(':element') {
          case []: 
            switch f.type {
              case TType(_.get() => {module: 'pine2.html.HtmlAttributes', name: name}, params):
                var prefix = switch name.split('Attr') {
                  case ['Global', '']: '';
                  case [name, '']: name;
                  default: throw 'assert';
                }
                Context.getType('js.html.${prefix}Element').toComplexType();
              default: 
                throw 'assert';
            }
          case [{params: [path]}]:
            Context.getType(path.toString()).toComplexType();
          default:
            Context.error('Invalid @:element', f.pos);
            throw 'assert';
        }
      else {
        macro:Dynamic;
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

private function getHtmlName(f:ClassField) {
  var htmlName = switch f.meta.extract(':html') {
    case []: 
      f.name;
    case [{params:[ { expr: EConst(CString(name, _)), pos: _ } ]}]: 
      name;
    default:
      Context.error('Invalid argument for :html', f.meta.extract(':html')[0].pos);
  }
}
