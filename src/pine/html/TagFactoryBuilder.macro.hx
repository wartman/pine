package pine.html;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;
import pine.macro.ClassBuilder;

using haxe.macro.Tools;
using pine.macro.MacroTools;

enum abstract TagKind(String) to String {
  var TagVoid = 'void';
  var TagNormal = 'normal';
  var TagOpaque = 'opaque';
}

typedef TagInfo = {
  name:String,
  kind:TagKind,
  type:Type,
  element:Type
}

class TagFactoryBuilder {
  public static function buildGeneric() {
    return switch Context.getLocalType() {
      case TInst(_, [type, TInst(_.get() => {kind: KExpr(macro true)}, _)]):
        buildFactory(type, true);
      case TInst(_, [type, TInst(_.get() => {kind: KExpr(macro false)}, _)]):
        buildFactory(type, false);
      default:
        throw 'assert';
    }
  }

  static function buildFactory(type:Type, isSvg:Bool):ComplexType {
    var pack = ['pine', 'html'];
    var name = 'TagFactory_' + type.stringifyTypeForClassName();
    var tagPath:TypePath = {pack: pack, name: name};

    if (!tagPath.typePathExists()) {
      var pos = Context.currentPos();
      var tags = getTags(type);
      var builder = new ClassBuilder([]);

      // @todo: handle ref

      for (tag in tags) {
        var name = tag.name;
        var attrs = tag.type.toComplexType();
        var ref = if (Context.defined('js') && !Context.defined('nodejs')) {
          var el = tag.element.toComplexType();
          macro:(el:$el) -> Void;
        } else {
          macro:(el:Dynamic) -> Void;
        }
        switch tag.kind {
          case TagNormal:
            builder.add(macro class {
              public static inline function $name(attrs : $attrs & pine.html.HtmlEvents & {?key:pine.Key}, ...children : pine.html.HtmlChild) {
                return new pine.html.HtmlElementComponent({
                  tag: $v{name},
                  attrs: attrs,
                  key: attrs.key,
                  isSvg: $v{isSvg},
                  children: children.toArray()
                });
              }
            });
          default:
            builder.add(macro class {
              public static inline function $name(attrs : $attrs & pine.html.HtmlEvents & {?key:pine.Key}) {
                return new pine.html.HtmlElementComponent({
                  tag: $v{name},
                  attrs: attrs,
                  isSvg: $v{isSvg},
                  key: attrs.key
                });
              }
            });
        }
      }

      Context.defineType({
        pack: pack,
        name: name,
        pos: pos,
        kind: TDClass(),
        fields: builder.export()
      });
    }

    return TPath(tagPath);
  }

  static function getTags(type:Type):Array<TagInfo> {
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
          case []: switch f.type {
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

    return tags;
  }

  // public static function createComponents(path:String, isSvg:Bool) {
  //   var type = Context.getType(path);
  //   var tags = getTags(type);
  //   for (tag in tags) {
  //     Context.defineType(createComponentType(['pine', 'html'], tag.name, tag.type.toComplexType(), isSvg));
  //   }
  // }
  // static function createComponentType(pack:Array<String>, name:String, attrs:ComplexType, isSvg:Bool):TypeDefinition {
  //   var clsName = name.charAt(0).toUpperCase() + name.substr(1);
  //   return {
  //     pack: pack,
  //     name: clsName,
  //     kind: TDClass({
  //       pack: ['pine', 'html'],
  //       name: 'HtmlElementComponent',
  //       params: [TPType(attrs)]
  //     }, [], false, true, false),
  //     pos: (macro null).pos,
  //     fields: (macro class {
  //       public function new(props:{
  //         attrs:$attrs & pine.html.HtmlEvents,
  //         ?key:pine.Key,
  //         ?children:Array<pine.Component>
  //       }) {
  //         super({
  //           tag: $v{name},
  //           attrs: props.attrs,
  //           children: props.children,
  //           isSvg: $v{isSvg},
  //           key: props.key
  //         });
  //       }
  //     }).fields
  //   };
  // }
}
