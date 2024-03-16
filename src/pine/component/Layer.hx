package pine.component;

import pine.component.Animation;
import pine.html.Html;

using pine.component.KeyboardModifier;

final DefaultShowAnimation = new Keyframes('show', context -> [ { opacity: 0 }, { opacity: 1 } ]);
final DefaultHideAnimation = new Keyframes('hide', context -> [ { opacity: 1 }, { opacity: 0 } ]);

class Layer extends Component {
  @:attribute final onShow:()->Void = null;
  @:attribute final onHide:()->Void;
  @:attribute final hideOnClick:Bool = true;
  @:attribute final hideOnEscape:Bool = true;
  @:attribute final child:Child;
  @:attribute final className:String = null;
  @:attribute final transitionSpeed:Int = 150;
  @:attribute final showAnimation:Keyframes = DefaultShowAnimation;
  @:attribute final hideAnimation:Keyframes = DefaultHideAnimation;

  function showPrimitive() {
    #if (js && !nodejs)
    var el:js.html.Element = getRealNode();
    el.style.visibility = 'visible';
    #end
  }

  function hidePrimitive() {
    #if (js && !nodejs)
    var el:js.html.Element = getRealNode();
    el.style.visibility = 'hidden';
    #end
  }

  function render() {
    var layer = new LayerContext();

    return Provider
      .provide(layer)
      .children({
        var body = Html.div()
          .attr(ClassName, className)
          .attr(Style, 'position:fixed;inset:0px;overflow-x:hidden;overflow-y:scroll;')
          .on(Click, e -> if (hideOnClick) {
            e.preventDefault();
            layer.hide();
          })
          .children(child);
        var animation = Animation.build({
          keyframes: layer.status.map(status -> switch status { 
            case Showing:
              showAnimation;
            case Hiding: 
              hideAnimation;
          }),
          duration: transitionSpeed,
          onStart: _ -> switch layer.status.peek() {
            case Showing:
              showPrimitive();
            case Hiding:
          },
          onFinished: _ -> switch layer.status.peek() {
            case Showing:
              if (onShow != null) onShow();
            case Hiding:
              hidePrimitive();
              if (onHide != null) onHide();
          },
          onDispose: _ -> {
            if (onHide != null) onHide();
          },
          child: body
        });

        LayerContainer.build({
          getFocusTarget: () -> child.getPrimitive(),
          hideOnEscape: hideOnEscape,
          child: animation
        });
      });
  }
}

class LayerContainer extends Component {
  @:attribute final getFocusTarget:()->Dynamic;
  @:attribute final hideOnEscape:Bool;
  @:children @:attribute final child:Child;

  function render():Child {
    if (hideOnEscape) return child.withKeyboardInputHandler((key, getModifierState) -> switch key {
      case Escape:
        LayerContext.from(this).hide();
      default:
    }, { preventDefault: false });
    
    return child;
  }

  #if (js && !nodejs)
  function setup() {
    var node = getFocusTarget().as(js.html.Element).toMaybe().orThrow();
    FocusContext.from(this).focus(node);
    addDisposable(() -> FocusContext.from(this).returnFocus());
  }
  #end
}
