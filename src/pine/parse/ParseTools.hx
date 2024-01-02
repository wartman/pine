package pine.parse;

using StringTools;

function isComponentName(name:String) {
  if (name.contains('.')) {
    var last = name.split('.').pop();
    return last.charAt(0).toUpperCase() == last.charAt(0);
  }
  return name.charAt(0).toUpperCase() == name.charAt(0);
}

inline function toPath(name:String):Array<String> {
  return name.split('.');
}
