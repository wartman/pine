package pine.html;

import haxe.macro.Context;
import pine.macro.ClassFieldCollection;

using StringTools;

function build() {
  var enumFields = new ClassFieldCollection(Context.getBuildFields());
  var names = Context.getType('pine.html.HtmlEvents');

  switch names {
    case TType(t, _): switch t.get().type {
      case TAnonymous(a):
        var refFields = a.get().fields;
        for (field in refFields) {
          var refName = field.name;

          if (refName.startsWith('on')) {
            refName = refName.substr(2);
          }

          var name = refName.charAt(0).toUpperCase() + refName.substr(1);
          var value = refName.toLowerCase();
          enumFields.add(macro class {
            final $name = $v{value};
          });
        }
      default: throw 'assert';
    }
    default: throw 'assert';
  }

  return enumFields.export();
}
