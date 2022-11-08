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
        
        // @todo: Check that complexType is valid

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
      case [ { params: [], pos: pos } ]:
        Context.error('Argument expected', pos);
      case [ { params: params, pos: pos } ]:
        Context.error('Too many arguments', params[1].pos);
      case metas:
        Context.error('Only one @component metadata is allowed per Element', metas[1].pos);
    }

    cls.meta.remove('component');
  }

  return builder.export();
}

function lcFirst(str:String) {
  var first = str.charAt(0).toLowerCase();
  return first + str.substr(1);
}
