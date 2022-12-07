package pine.html.server;

import haxe.DynamicAccess;
import pine.object.Object;

using pine.core.ObjectTools;

class HtmlElementObject extends Object {
  static final VOID_ELEMENTS = [
    'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr',
  ];

  public final tag:String;
  public final attributes:{};

  public function new(tag, attributes) {
    this.tag = tag;
    this.attributes = attributes;
  }

  public function updateAttributes(newAttrs:{}) {
    attributes.diff(newAttrs, (key, oldValue, newValue) -> {
      if (newValue == null) {
        Reflect.deleteField(attributes, key);
      } else {
        Reflect.setField(attributes, key, newValue);
      }
    });
  }

  public function toString():String {
    var attrs:Map<String, String> = getFilteredAttributes();
    var children:Array<String> = children.filter(c -> c != null).map(c -> c.toString());

    if (tag == '#document' || tag == '#fragment') {
      return children.join('');
    }

    var tag = switch tag.split(':') {
      case [_, name]: name;
      default: tag;
    }

    var out = '<${tag}';
    var attrs = [for (key => value in attrs) '$key="$value"'];
    if (attrs.length > 0) out += ' ${attrs.join(' ')}';

    // todo: handle innerHTML.

    return if (VOID_ELEMENTS.contains(tag)) {
      out + '/>';
    } else if (children.length > 0) {
      out + '>' + children.join('') + '</${tag}>';
    } else {
      out + '></${tag}>';
    }
  }

  @:nullSafety(Off)
  function getFilteredAttributes():Map<String, String> {
    var attrs:DynamicAccess<Dynamic> = attributes;
    var out:Map<String, String> = [];

    for (key => value in attrs) {
      if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
        // noop
      } else if (Reflect.isFunction(value)) {
        // noop
      } else if (value == null || value == false) {
        // noop
      } else if (key == 'className') {
        out.set('class', value);
      } else if (value == true) {
        out.set(key, key);
      } else {
        out.set(key, Std.string(value));
      }
    }

    return out;
  }
}
