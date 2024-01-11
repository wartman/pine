package pine.html;

import pine.macro.ClassFieldCollection;
import haxe.macro.Context;

function build() {
  var fields = new ClassFieldCollection(Context.getBuildFields());
  var tags = Context.getType('pine.html.HtmlTags');
  var tagFields = switch tags {
    case TType(t, _): switch t.get().type {
      case TAnonymous(a): a.get().fields;
      default: throw 'assert';
    }
    default: throw 'assert';
  }

  for (tag in tagFields) {
    var name = tag.name;
    fields.add(macro class {
      public static inline function $name() {
        return build($v{name});
      }
    });
  }

  return fields.export();
}
