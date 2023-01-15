package pine.debug.html;

import haxe.Exception;
import pine.element.BoundaryElementEngine;
import pine.html.*;

using Type;
using pine.core.OptionTools;

// @todo: This is still pretty useless, but you should be able
// to get where this is going.

class VisualErrorBoundary extends AutoComponent {
  final child:HtmlChild;

  public function render(context:Context):Component {
    return new ErrorBoundary({
      render: _ -> child,
      fallback: displayError
    });
  }

  inline function displayError(thrown:ThrownObject) {
    var children:Array<Component> = [];

    #if !debug
    children.push(new Html<'p'>({ children: 'An unhandled exception occurred' }));
    #else
    var e:Exception = thrown.object;
    children.push(new Html<'p'>({ children: [ 'An exception occurred: ', e.message ] }));
    
    var element:Null<Element> = thrown.element;
    var node = new ElementTreeNode({ describe: element });

    while (element != null) {
      element = element != null ? element.getParent().unwrap() : null;
      if (element != null) {
        node = new ElementTreeNode({ describe: element, child: node });
      }
    }

    children.push(node);
    #end

    // @todo: In debug mode we need to show the stack-trace too.
    // @todo: We should also be able to expand the entire component
    // tree list, not just individual parts.
    return new Html<'div'>({
      style: 'background-color:red;color:white;padding:15px;',
      children: children
    }); 
  }
}

class ElementTreeNode extends AutoComponent {
  final describe:Element;
  final child:Null<Component> = null;
  final open:Bool = false;

  function render(context:Context) {
    var component = @:nullSafety(Off) describe.component.getClass().getClassName();
    
    return new TreeNode({
      open: open,
      label: new Html<'span'>({
        style: switch describe.status {
          case Failed(_): 'font-weight:bold'; // @todo: something better
          default: '';
        },
        children: component
      }),
      children: child == null ? [] : [ child ]
    });
  }
}

class TreeNode extends AutoComponent {
  final label:HtmlChild;
  final children:HtmlChildren;
  var open:Bool;
  
  function render(context:Context) {
    return new Html<'div'>({
      style: 'margin-left:10px;cursor:pointer',
      children: [
        new Html<'div'>({
          onclick: e -> open = !open,
          children: [ label ]
        }),
        new Html<'div'>({
          style: if (open) '' else 'display: none',
          children: children
        })
      ]
    });
  }
}
