package pine.debug;

import pine.render.Object;

using Type;

// @todo: This is just a bit of a placeholder.
class DebugNode extends Object {
  public final el:Element;
  public final isTarget:Bool;

  public function new(el, isTarget = false) {
    this.el = el;
    this.isTarget = isTarget;
  }

  // Note: nullSafety doesn't seem to like `getClass`. 
  @:nullSafety(Off) 
  public function toString():String {
    var component:Component = el.getComponent();
    var name = el.getClass().getClassName();

    if (component != null) {
      name = component.getClass().getClassName() + ' | ' + name;
    }

    if (isTarget) {
      name = '*' + name;
    }

    var depth = getDepth();
    var spaces = [ for (_ in 0...depth) '  ' ].join('');
    var out = [ spaces + name ].concat([ for (child in children) child.toString() ]);
    
    return out.join('\n');
  }

  function getDepth() {
    var depth = 0;
    var n = parent;
    while (n != null) {
      depth++;
      n = n.parent;
    }
    return depth;
  }
}
