package pine.component;

import pine.component.Animated;

function withAnimation(child:Child, id:String, factory, ?options:{
  ?easing:String,
  ?duration:Int
}) {
  return Animated.build({
    keyframes: new Keyframes(id, factory),
    duration: options?.duration ?? 300,
    easing: options?.easing,
    child: child
  });
}

function withInfiniteAnimation(child:Child, id:String, factory, ?options:{
  ?easing:String,
  ?duration:Int
}) {
  return Animated.build({
    keyframes: new Keyframes(id, factory),
    duration: options?.duration ?? 300,
    easing: options?.easing,
    child: child,
    infinite: true
  });
}
