package pine.component;

import pine.component.Animation;
import pine.html.Html;
import pine.signal.*;

using Lambda;
using pine.Modifier;

// @todo: This component is using most of the implementation from
// Blok, which unfortunately seems completely broken in Pine (at least
// with dragging). Unsure why right now.
class CarouselViewport extends Component {
  @:attribute final className:String = null;
  @:attribute final duration:Int = 200;
  @:attribute final dragClamp:Int = 50;
  @:children @:attribute final children:Children;

  // @todo: These controls have some issues. First, we need to make 
  // sure that only left-clicks (or single finger touches) have an effect.
  // ...and that's all I can think of right now? I'm sure there's more.
  //
  // We should make the drag behavior optional, I suppose.

  var target:Maybe<Animation> = None;

  #if (js && !nodejs)
  var startDrag:Float = -1;
  var previousDrag:Float = 0;
  var dragOffset:Float = 0;

  function getTarget() {
    return target
      .flatMap(component -> component.getPrimitive().as(js.html.Element).toMaybe())
      .orThrow('Could not find Animation child -- `getTarget` may have been called before the component rendered');
  }

  function isValidInteraction(e:js.html.Event) {
    return switch Std.downcast(e, js.html.TouchEvent) {
      case null: 
        var mouse = e.as(js.html.MouseEvent);
        mouse.buttons == 1 && mouse.button == 0;
      case touch:
        // @todo: not sure if the following is enough
        touch.touches.length == 1;
    }
  }

  function getInteractionPosition(e:js.html.Event) {
    return switch Std.downcast(e, js.html.TouchEvent) {
      case null: 
        e.as(js.html.MouseEvent).clientX;
      case touch: 
        touch.changedTouches.item(0).clientX;
    }
  }

  function onDragStart(e:js.html.Event) {
    // @todo: Potentially check the event target and don't drag if it's 
    // text.

    if (!isValidInteraction(e)) return;
    
    e.preventDefault();
    startDrag = getInteractionPosition(e);
    previousDrag = startDrag;

    js.Browser.window.addEventListener('mousemove', onDragUpdate);
    js.Browser.window.addEventListener('mouseup', onDragEnd);
    js.Browser.window.addEventListener('touchmove', onDragUpdate);
    js.Browser.window.addEventListener('touchend', onDragEnd);
  }

  function onDragUpdate(e:js.html.Event) {
    if (!isValidInteraction(e)) return;

    var context = CarouselContext.from(this);
    var currentDrag = getInteractionPosition(e);
    var offset = previousDrag - currentDrag;

    if (startDrag > currentDrag && context.hasNext()) {
      dragOffset += offset;
      updateViewportTransform();
    }
  
    if (startDrag < currentDrag && context.hasPrevious()) {
      dragOffset += offset;
      updateViewportTransform();
    }

    previousDrag = currentDrag;
  }

  function onDragEnd(e:js.html.Event) {
    e.preventDefault();

    js.Browser.window.removeEventListener('mousemove', onDragUpdate);
    js.Browser.window.removeEventListener('mouseup', onDragEnd);
    js.Browser.window.removeEventListener('touchmove', onDragUpdate);
    js.Browser.window.removeEventListener('touchend', onDragEnd);
    
    var endDrag = getInteractionPosition(e);
    var context = CarouselContext.from(this);
    var amount = startDrag - endDrag;
    
    if (Math.abs(amount) < dragClamp) {
      dragOffset = 0;
      updateViewportTransform();
      return;
    }

    if (startDrag > endDrag && context.hasNext()) {
      context.next();
      return;
    }
  
    if (startDrag < endDrag && context.hasPrevious()) {
      context.previous();
      return;
    }

    resetViewportTransform();
  }

  function getCurrentPosition() {
    var carousel = CarouselContext.from(this);
    return Runtime.current().untrack(() -> carousel.getPosition().current);
  }

  function getOffset(position:Int) {
    var slides = CarouselContext.from(this).slides;
    return slides.find(slide -> slide.position == position)
      ?.getPrimitive()
      ?.as(js.html.Element)
      ?.offsetLeft
      ?? 0.0;
  }

  function updateViewportTransform() {
    var offset = getOffset(getCurrentPosition()) + dragOffset;
    getTarget().style.transform = 'translate3d(-${offset}px, 0px, 0px)';
  }

  function resetViewportTransform() {
    dragOffset = 0;
    updateViewportTransform();
  }

  function setup() {
    var window = js.Browser.window;
    window.addEventListener('resize', resetViewportTransform);
    addDisposable(() -> {
      window.removeEventListener('resize', resetViewportTransform);
      window.removeEventListener('mousemove', onDragUpdate);
      window.removeEventListener('mouseup', onDragEnd);
      window.removeEventListener('touchmove', onDragUpdate);
      window.removeEventListener('touchend', onDragEnd);
    });
  }
  #else
  function getOffset(_:Int) {
    return 0.0;
  }
  #end

  function render():Child {
    var carousel = CarouselContext.from(this);
    // // @todo: For some reason this worked fine in Block, but here we're
    // // trying to get an offset from Components that have not mounted yet.
    // //
    // // Also, and I'm not sure if this is the cause, the Carousel is entirely
    // // broken when using mouse dragging.
    // var currentOffset = Runtime.current().untrack(() -> getOffset(carousel.getPosition().current));
    var body = Html.div()
      #if (js && !nodejs)
      .on(MouseDown, onDragStart)
      .on(TouchStart, onDragStart)
      #end
      .attr(ClassName, className)
      .attr(Style, 'overflow:hidden')
      .children(
        (target = Some(Animation.build({
          keyframes: new Keyframes('blok.foundation.carousel', context -> {
            var pos = carousel.getPosition();
            #if (js && !nodejs)
            var currentOffset = getOffset(pos.previous) + dragOffset;
            #else
            var currentOffset = getOffset(pos.previous);
            #end
            var nextOffset = getOffset(pos.current);
      
            return [
              { transform: 'translate3d(-${currentOffset}px, 0px, 0px)' },
              { transform: 'translate3d(-${nextOffset}px, 0px, 0px)' },
            ];
          }),
          #if (js && !nodejs)
          onFinished: _ -> resetViewportTransform(),
          #end
          animateInitial: false,
          repeatCurrentAnimation: true,
          // @todo: Duration should be based off the width of the screen.
          duration: duration,
          child: Html.div()
            // .attr(Style, 'display:flex;height:100%;width:100%;transform:translate3d(-${currentOffset}px, 0px, 0px)')
            .attr(Style, 'display:flex;height:100%;width:100%;transform:translate3d(0px, 0px, 0px)')
            .children(children)
        }))).unwrap()
      );

    #if (js && !nodejs)
    return body.build().onMount(setup);
    #else
    return body;
    #end
  }
}
