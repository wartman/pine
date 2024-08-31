package pine.parse;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using Lambda;
using StringTools;
using haxe.macro.Tools;
using kit.macro.Tools;

class Tag {
	public static final fromMarkupMeta = ':fromMarkup';

	public static function fromType(locatedName:Located<String>, type:Type, mode:TagMode = FromCustom):Tag {
		var name = locatedName.value;
		var pos = locatedName.pos;
		var reject = createRejector(name, pos);

		return switch type {
			case TLazy(f):
				fromType(locatedName, f(), mode);
			case TInst(t, _):
				var cls = t.get();
				var statics = cls.statics.get();
				var field = statics.find(f -> f.meta.has(fromMarkupMeta));

				if (field == null) {
					reject('it does not have a [$fromMarkupMeta] static method.');
				}

				processType(name, cls.pack.concat([cls.name]).join('.'), field.type, Custom(FromMarkupMethod(field.name)), pos);
			case TType(_.get() => {pack: [], name: t}, []) if (t.startsWith('Class<')):
				fromType(locatedName, Context.getType(name), mode);
			case TType(t, []):
				fromType(locatedName, t.get().type, mode);
			case TFun(_, _):
				processType(name, name, type, Custom(FunctionCall), pos);
			case TAnonymous(_): switch mode {
					case FromPrimitive:
						processType(name, name, type, Primitive, pos);
					default:
						reject('it is not a valid function');
				}
			default:
				reject('it is not a valid function');
		}
	}

	public final name:String;
	public final fullName:String;
	public final kind:TagKind;
	public final attributes:TagAttributes;

	public function new(name, fullName, kind, attributes) {
		this.name = name;
		this.fullName = fullName;
		this.kind = kind;
		this.attributes = attributes;
	}
}

@:structInit
class TagAttributes {
	public final fields:Map<String, ClassField>;
	public final attributesType:Type;
	public final childrenAttribute:TagChildrenAttribute;

	public function getAttribute(name:Located<String>) {
		return fields.get(name.value);
	}

	public function hasAttribute(name:Located<String>) {
		return fields.exists(name.value);
	}
}

enum TagMode {
	FromCustom;
	FromPrimitive;
}

enum TagKind {
	Primitive;
	Custom(kind:TagCustomKind);
}

enum TagCustomKind {
	FunctionCall;
	FromMarkupMethod(method:String);
}

enum TagChildrenAttribute {
	None;
	Field(name:String);
}

private function createRejector(name:String, pos:Position) {
	return (reason:String) -> Context.error('$name is not valid markup: $reason', pos);
}

private function processType(name:String, path:String, type:Type, kind:TagKind, pos:Position):Tag {
	var reject = createRejector(name, pos);
	var createTag = (t:Type) -> switch t {
		case TAnonymous(a):
			var obj = a.get();
			var fields:Map<String, ClassField> = [];
			var childrenAttr:TagChildrenAttribute = None;

			for (field in obj.fields) {
				fields.set(field.name, field);
				if (field.meta.has(':children')) switch childrenAttr {
					case None:
						childrenAttr = Field(field.name);
					case Field(name):
						Context.error('Cannot have more than one field acting as children: ${name} already marked', field.pos);
				}

				switch field.meta.extract(':attr') {
					case [alias]: switch alias.params {
							case [{expr: EConst(CString(s, _)), pos: _}]:
								fields.set(s, field);
							default:
								alias.pos.error('Expected a single string');
						}
					default:
				}
			}

			new Tag(name, path, kind, {
				fields: fields,
				attributesType: t,
				childrenAttribute: childrenAttr
			});
		default:
			reject('it must be an anonymous object');
	}

	return switch type {
		case TLazy(f):
			processType(name, path, f(), kind, pos);
		case TFun(args, ret):
			args = args.copy();
			switch args {
				case [] if (kind.match(Custom(FromMarkupMethod(_)))):
					reject('its ${Tag.fromMarkupMeta} method has no arguments (expected at least one)');
				case []:
					reject('it has no arguments (expected at least one)');
				case [props]:
					createTag(props.t);
				default:
					reject('it has too many arguments (expected at most one)');
			}
		case TAnonymous(_): switch kind {
				case Primitive:
					createTag(type);
				default:
					reject('it is not a function');
			}
		case _ if (kind.match(Custom(FromMarkupMethod(_)))):
			reject('its ${Tag.fromMarkupMeta} field is not a function');
		default:
			reject('it is not a function');
	}
}
