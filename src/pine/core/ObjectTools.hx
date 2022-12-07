package pine.core;

using Reflect;

private final empty = {};

function diff(
  oldFields:Null<{}>,
  newFields:Null<{}>,
  apply:(key:String, oldValue:Null<Dynamic>, newValue:Null<Dynamic>) -> Void
):Void {
  if (oldFields == newFields) return;

  var keys:Array<String> = switch [ newFields, oldFields ] {
    case [ null, null ]: 
      newFields = empty;
      oldFields = empty;
      [];
    case [ null, fields ]:
      newFields = empty;
      fields.fields();
    case [ fields, null ]:
      oldFields = empty;
      fields.fields();
    case [ olds, news ]:
      var keys = news.fields();
      for (key in olds.fields()) if (!keys.contains(key)) keys.push(key);
      keys;
  }

  for (key in keys) switch [ oldFields.field(key), newFields.field(key) ] {
    case [ a, b ] if (a == b):
    case [ a, b ]: apply(key, a, b);
  }
}

function merge(a:{}, b:{}):{} {
  if (a == b) return a;

  var object:{} = cast a.copy();

  diff(a, b, (key, oldValue, newValue) -> {
    if (newValue != null) {
      object.setField(key, newValue);
    } else {
      object.deleteField(key);
    }
  });

  return object;
}
