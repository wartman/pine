package pine.component;

#if ((js && !nodejs) || pine.client)
import js.Browser.window;
import js.html.Animation;
import js.html.Element;
import pine.signal.Observer;
#end

using Reflect;
using pine.Modifier;

@:forward
abstract Keyframes({
  public final id:String;
  public final factory:(context:View)->Array<{}>;
}) {
  public inline function new(id, factory) {
    this = { id: id, factory: factory };
  }

  public inline function equals(other:Keyframes) {
    return this.id == other.id;
  }

  public inline function create(context) {
    return this.factory(context);
  }
}

class Animated extends Component {
  @:observable final keyframes:Keyframes;
  @:attribute final duration:Int;
  @:attribute final animateInitial:Bool = true;
  @:attribute final repeatCurrentAnimation:Bool = false;
  @:attribute final infinite:Bool = false;
  @:attribute final easing:String = 'linear';
  @:attribute final onStart:(context:Component)->Void = null;
  @:attribute final onFinished:(context:Component)->Void = null;
  @:attribute final onDispose:(context:Component)->Void = null;
  @:children @:attribute final child:Child;
  
  #if ((js && !nodejs) || pine.client)
  var currentKeyframes:Null<Keyframes> = null;
  var currentAnimation:Null<Animation> = null;

  function render() {
    var first = true;
    return child.withEffect(() -> {
      registerAnimation(first);
      first = false;
      return () -> {
        currentAnimation?.cancel();
        currentAnimation = null;
      }
    });
  }

  function registerAnimation(first:Bool = false) {
    switch __status {
      case Disposed: return;
      default:
    }

    var el:Element = getPrimitive();
    var duration = if (first && !animateInitial) 0 else duration;
    var keyframes = keyframes();

    if (!repeatCurrentAnimation) {
      if (currentKeyframes != null && currentKeyframes.equals(keyframes)) {
        return;
      }
    }

    currentKeyframes = keyframes;
    
    if (currentAnimation != null) {
      currentAnimation.cancel();
      currentAnimation = null;
    }
    
    function onFinished() {
      currentAnimation = null;
      if (this.onFinished != null) this.onFinished(this);
    }

    if (onStart != null) onStart(this);

    currentAnimation = registerAnimations(el, keyframes.create(this), {
      duration: duration,
      easing: easing,
      iterations: if (infinite) Math.POSITIVE_INFINITY else 1
    }, onFinished);
  }
  #else
  function render() {
    return child;
  }
  #end
}

#if ((js && !nodejs) || pine.client)
private typedef AnimationOptions = {
  public final duration:Int;
  public final ?easing:String;
  public final ?iterations:Float;
}

private function registerAnimations(el:Element, keyframes:Array<Dynamic>, options:AnimationOptions, onFinished:()->Void):Animation {
  var duration = prefersReducedMotion() ? 0 : options.duration;
  var animation = el.animate(keyframes, { 
    duration: duration,
    easing: options.easing,
    iterations: options.iterations
  });
  
  // @todo: I don't think we want to trigger finished if we're canceling.
  // animation.addEventListener('cancel', onFinished, { once: true });
  animation.addEventListener('finish', onFinished, { once: true });

  return animation;
}

private function stopAnimations(el:Element, onFinished:()->Void) {
  kit.Task.parallel(...el.getAnimations().map(animation -> new kit.Task(activate -> {
    animation.addEventListener('cancel', () -> activate(Ok(null)), { once: true });
    animation.addEventListener('finish', () -> activate(Ok(null)), { once: true });
    animation.cancel();
  }))).handle(_ -> onFinished());
}

private function prefersReducedMotion() {
  var query = window.matchMedia('(prefers-reduced-motion: reduce)');
  return query.matches;
}
#end
