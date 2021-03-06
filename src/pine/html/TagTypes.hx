package pine.html;

final types:Map<String, UniqueId> = [];

function getTypeForTag(tag:String):UniqueId {
  var type = types.get(tag);
  if (type == null) {
    type = new UniqueId();
    types.set(tag, type);
  }
  return type;
}
