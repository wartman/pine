package pine.parse;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using haxe.macro.Tools;
using pine.parse.ParseTools;
using pine.macro.Tools;

// @todo: Figure out how to get this thing to enable completion.
class Generator {
  var context:TagContext;

  public function new(context) {
    this.context = context;
  }

  public function generate(nodes:Array<Node>) {
    var exprs = [ for (node in nodes) generateNode(node) ];
    return switch exprs {
      case []: macro null;
      case [expr]: expr;
      case exprs: macro pine.Fragment.of([ $a{exprs} ]);
    }
  }

  public function generateNode(node:Node):Expr {
    return switch node.value {
      case NFragment(children):
        var components = children.map(generateNode);
        macro @:pos(node.pos) pine.Fragment.of([ $a{components} ]);
      case NNode(name, attributes, nodeChildren):
        var tag = context.resolve(name);
        var expr:Expr = switch tag.kind {
          case Primitive:
            var children = switch tag.attributes.childrenAttribute {
              case None if (nodeChildren != null && nodeChildren.length > 0):
                Context.error('The tag ${tag.name} does not allow children', nodeChildren[0].pos);
              case None: 
                macro [];
              case Field(name) if (attributes.exists(attr -> attr.name.value == name)):
                var attr = attributes.find(attr -> attr.name.value == name);

                if (nodeChildren != null && nodeChildren.length > 0) {
                  attr.name.pos.error('You cannot use the ${name} attribute and provide node children at the same time');  
                }
                
                attributes.remove(attr);
                attr.value;
              case Field(_) if (nodeChildren == null):
                macro [];
              case Field(_):
                var exprs = [ for (child in nodeChildren) generateNode(child) ];
                macro [ $a{exprs} ];
            }
            var ref = switch attributes.find(attr -> attr.name.value == 'ref') {
              case null:
                macro null;
              case attr:
                attributes.remove(attr);
                attr.value;
            }
            var attrExprs = [ for (attr in attributes) {
              var field = tag.attributes.getAttribute(attr.name);
              
              if (field == null) {
                attr.name.pos.error('Invalid attribute');
              }

              var attrType = field.type.toComplexType();
              var name = attr.name.value;
              var expr = macro @:pos(attr.value.pos) (${attr.value}:pine.signal.Signal.ReadOnlySignal<$attrType>);
              
              macro @:pos(attr.name.pos) $v{name} => $expr;
            } ];
            macro @:pos(name.pos) new pine.PrimitiveView(
              $v{tag.name},
              [ $a{attrExprs} ],
              $children,
              $ref
            );
          case Custom(kind):
            var props:Array<ObjectField> = [];

            function addProp(attr:Attribute) {
              if (props.exists(p -> p.field == attr.name.value)) {
                attr.name.pos.error('Attribute already exists');
              }
              props.push({
                field: attr.name.value,
                expr: attr.value
              });
            }

            for (attr in attributes) {
              var attrType = tag.attributes.getAttribute(attr.name);
              if (attrType == null) {
                attr.name.pos.error('Invalid attribute');
              }
              addProp(attr);
            }

            switch tag.attributes.childrenAttribute {
              case None if (nodeChildren != null && nodeChildren.length > 0):
                Context.error('The tag ${tag.name} does not allow children', nodeChildren[0].pos);
              case Field(name) if (nodeChildren.length > 0):
                addProp({
                  name: {
                    value: name,
                    pos: Context.makePosition({
                      min: nodeChildren[0].pos.getInfos().min,
                      max: nodeChildren[nodeChildren.length - 1].pos.getInfos().max,
                      file: nodeChildren[0].pos.getInfos().file,
                    })
                  },
                  value: generate(nodeChildren)
                });
              default:
            }

            var args:Array<Expr> = [{
              expr: EObjectDecl(props),
              pos: name.pos
            }];
            var path:Array<String> = name.value.toPath();

            switch kind {
              case FunctionCall:
                var caller = macro @:pos(name.pos) $p{path};
                macro $caller($a{args});
              case FromMarkupMethod(method):
                var path = path.concat([method]);
                var caller = macro @:pos(name.pos) $p{path};
                macro $caller($a{args});
            }
        }

        if (Context.containsDisplayPosition(name.pos)) {
          expr = {expr: EDisplay(expr, DKMarked), pos: expr.pos};
        }

        expr;
      case NText(text):
        macro pine.Text.build($v{text});
      case NExpr(expr):
        expr;
    }
  }
}