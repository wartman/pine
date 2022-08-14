package pine.debug;

function locateElementInTree(el:Element) {
  var node = new DebugNode(el, true);
  var parent = el.getParent();
  
  while (parent != null) {
    var parentNode = new DebugNode(parent);
    parentNode.append(node);
    node = parentNode;
    parent = parent.getParent();
  }

  return node;
}
