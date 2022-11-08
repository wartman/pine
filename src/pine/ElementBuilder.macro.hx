package pine;

import haxe.macro.Context;
import pine.macro.ClassBuilder;

using haxe.macro.Tools;
using StringTools;

function build() {
  var builder = new ClassBuilder(Context.getBuildFields());
  var cls = Context.getLocalClass().get();

  if (cls.meta.has('component')) {
    switch cls.meta.extract('component') {
      case [ { params: [ type ], pos: pos } ]:
        var name = lcFirst(type.toString().split('.').pop());
        var getter = 'get_$name';
        var complexType = type.toString().toComplex();
        
        builder.add(macro class {
          var $name(get, never):$complexType;
          inline function $getter():$complexType return getComponent();
        });

        switch builder.findField('new') {
          case Some(_):
          case None: builder.add(macro class {
            public function new($name:$complexType) {
              super($i{name});
            }
          });
        }

      case [ { params: _, pos: pos } ]:
        Context.error('Invalid arguments', pos);
      default:
        Context.error('Invalid metadata', cls.pos);
    }

    cls.meta.remove('component');
  }

  return builder.export();
}

function lcFirst(str:String) {
  var first = str.charAt(0).toLowerCase();
  return first + str.substr(1);
}
