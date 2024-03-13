package pine.html.server;

using Kit;

function findAncestor(primitive:Primitive, match:(parent:Primitive)->Bool):Maybe<Primitive> {
  var parent = primitive.parent;
  if (parent == null) return None;
  if (match(parent)) return Some(parent);
  return findAncestor(parent, match);
}
