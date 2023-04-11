package pine.html;

import pine.signal.Signal;

#if (js && !nodejs)
typedef Event = js.html.Event;
#else
typedef Event = Dynamic;
#end
typedef EventListener = (e:Event) -> Void;

// From https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Events.hx
typedef HtmlEvents = {
  @:optional final onwheel:ReadonlySignal<EventListener>;
  @:optional final oncopy:ReadonlySignal<EventListener>;
  @:optional final oncut:ReadonlySignal<EventListener>;
  @:optional final onpaste:ReadonlySignal<EventListener>;
  @:optional final onabort:ReadonlySignal<EventListener>;
  @:optional final onblur:ReadonlySignal<EventListener>;
  @:optional final onfocus:ReadonlySignal<EventListener>;
  @:optional final oncanplay:ReadonlySignal<EventListener>;
  @:optional final oncanplaythrough:ReadonlySignal<EventListener>;
  @:optional final onchange:ReadonlySignal<EventListener>;
  @:optional final onclick:ReadonlySignal<EventListener>;
  @:optional final oncontextmenu:ReadonlySignal<EventListener>;
  @:optional final ondblclick:ReadonlySignal<EventListener>;
  @:optional final ondrag:ReadonlySignal<EventListener>;
  @:optional final ondragend:ReadonlySignal<EventListener>;
  @:optional final ondragenter:ReadonlySignal<EventListener>;
  @:optional final ondragleave:ReadonlySignal<EventListener>;
  @:optional final ondragover:ReadonlySignal<EventListener>;
  @:optional final ondragstart:ReadonlySignal<EventListener>;
  @:optional final ondrop:ReadonlySignal<EventListener>;
  @:optional final ondurationchange:ReadonlySignal<EventListener>;
  @:optional final onemptied:ReadonlySignal<EventListener>;
  @:optional final onended:ReadonlySignal<EventListener>;
  @:optional final oninput:ReadonlySignal<EventListener>;
  @:optional final oninvalid:ReadonlySignal<EventListener>;
  @:optional final oncompositionstart:ReadonlySignal<EventListener>;
  @:optional final oncompositionupdate:ReadonlySignal<EventListener>;
  @:optional final oncompositionend:ReadonlySignal<EventListener>;
  @:optional final onkeydown:ReadonlySignal<EventListener>;
  @:optional final onkeypress:ReadonlySignal<EventListener>;
  @:optional final onkeyup:ReadonlySignal<EventListener>;
  @:optional final onload:ReadonlySignal<EventListener>;
  @:optional final onloadeddata:ReadonlySignal<EventListener>;
  @:optional final onloadedmetadata:ReadonlySignal<EventListener>;
  @:optional final onloadstart:ReadonlySignal<EventListener>;
  @:optional final onmousedown:ReadonlySignal<EventListener>;
  @:optional final onmouseenter:ReadonlySignal<EventListener>;
  @:optional final onmouseleave:ReadonlySignal<EventListener>;
  @:optional final onmousemove:ReadonlySignal<EventListener>;
  @:optional final onmouseout:ReadonlySignal<EventListener>;
  @:optional final onmouseover:ReadonlySignal<EventListener>;
  @:optional final onmouseup:ReadonlySignal<EventListener>;
  @:optional final onpause:ReadonlySignal<EventListener>;
  @:optional final onplay:ReadonlySignal<EventListener>;
  @:optional final onplaying:ReadonlySignal<EventListener>;
  @:optional final onprogress:ReadonlySignal<EventListener>;
  @:optional final onratechange:ReadonlySignal<EventListener>;
  @:optional final onreset:ReadonlySignal<EventListener>;
  @:optional final onresize:ReadonlySignal<EventListener>;
  @:optional final onscroll:ReadonlySignal<EventListener>;
  @:optional final onseeked:ReadonlySignal<EventListener>;
  @:optional final onseeking:ReadonlySignal<EventListener>;
  @:optional final onselect:ReadonlySignal<EventListener>;
  @:optional final onshow:ReadonlySignal<EventListener>;
  @:optional final onstalled:ReadonlySignal<EventListener>;
  @:optional final onsubmit:ReadonlySignal<EventListener>;
  @:optional final onsuspend:ReadonlySignal<EventListener>;
  @:optional final ontimeupdate:ReadonlySignal<EventListener>;
  @:optional final onvolumechange:ReadonlySignal<EventListener>;
  @:optional final onwaiting:ReadonlySignal<EventListener>;
  @:optional final onpointercancel:ReadonlySignal<EventListener>;
  @:optional final onpointerdown:ReadonlySignal<EventListener>;
  @:optional final onpointerup:ReadonlySignal<EventListener>;
  @:optional final onpointermove:ReadonlySignal<EventListener>;
  @:optional final onpointerout:ReadonlySignal<EventListener>;
  @:optional final onpointerover:ReadonlySignal<EventListener>;
  @:optional final onpointerenter:ReadonlySignal<EventListener>;
  @:optional final onpointerleave:ReadonlySignal<EventListener>;
  @:optional final ongotpointercapture:ReadonlySignal<EventListener>;
  @:optional final onlostpointercapture:ReadonlySignal<EventListener>;
  @:optional final onfullscreenchange:ReadonlySignal<EventListener>;
  @:optional final onfullscreenerror:ReadonlySignal<EventListener>;
  @:optional final onpointerlockchange:ReadonlySignal<EventListener>;
  @:optional final onpointerlockerror:ReadonlySignal<EventListener>;
  @:optional final onerror:ReadonlySignal<EventListener>;
  @:optional final ontouchstart:ReadonlySignal<EventListener>;
  @:optional final ontouchend:ReadonlySignal<EventListener>;
  @:optional final ontouchmove:ReadonlySignal<EventListener>;
  @:optional final ontouchcancel:ReadonlySignal<EventListener>;
}
