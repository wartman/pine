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
  @:html('onwheel') final ?onWheel:ReadonlySignal<EventListener>;
  @:html('oncopy') final ?onCopy:ReadonlySignal<EventListener>;
  @:html('oncut') final ?onCut:ReadonlySignal<EventListener>;
  @:html('onpaste') final ?onPaste:ReadonlySignal<EventListener>;
  @:html('onabort') final ?onAbort:ReadonlySignal<EventListener>;
  @:html('onblur') final ?onBlur:ReadonlySignal<EventListener>;
  @:html('onfocus') final ?onFocus:ReadonlySignal<EventListener>;
  @:html('oncanplay') final ?onCanPlay:ReadonlySignal<EventListener>;
  @:html('oncanplaythrough') final ?onCanPlayThrough:ReadonlySignal<EventListener>;
  @:html('onchange') final ?onChange:ReadonlySignal<EventListener>;
  @:html('onclick') final ?onClick:ReadonlySignal<EventListener>;
  @:html('oncontextmenu') final ?onContextMenu:ReadonlySignal<EventListener>;
  @:html('ondblclick') final ?onDblClick:ReadonlySignal<EventListener>;
  @:html('ondrag') final ?onDrag:ReadonlySignal<EventListener>;
  @:html('ondragend') final ?onDragEnd:ReadonlySignal<EventListener>;
  @:html('ondragenter') final ?onDragEnter:ReadonlySignal<EventListener>;
  @:html('ondragleave') final ?onDragLeave:ReadonlySignal<EventListener>;
  @:html('ondragover') final ?onDragOver:ReadonlySignal<EventListener>;
  @:html('ondragstart') final ?onDragStart:ReadonlySignal<EventListener>;
  @:html('ondrop') final ?onDrop:ReadonlySignal<EventListener>;
  @:html('ondurationchange') final ?onDurationChange:ReadonlySignal<EventListener>;
  @:html('onemptied') final ?onEmptied:ReadonlySignal<EventListener>;
  @:html('onended') final ?onEnded:ReadonlySignal<EventListener>;
  @:html('oninput') final ?onInput:ReadonlySignal<EventListener>;
  @:html('oninvalid') final ?onInvalid:ReadonlySignal<EventListener>;
  @:html('oncompositionstart') final ?onCompositionStart:ReadonlySignal<EventListener>;
  @:html('oncompositionupdate') final ?onCompositionUpdate:ReadonlySignal<EventListener>;
  @:html('oncompositionend') final ?onCompositionEnd:ReadonlySignal<EventListener>;
  @:html('onkeydown') final ?onKeyDown:ReadonlySignal<EventListener>;
  @:html('onkeypress') final ?onKeyPress:ReadonlySignal<EventListener>;
  @:html('onkeyup') final ?onKeyUp:ReadonlySignal<EventListener>;
  @:html('onload') final ?onLoad:ReadonlySignal<EventListener>;
  @:html('onloadeddata') final ?onLoadedData:ReadonlySignal<EventListener>;
  @:html('onloadedmetadata') final ?onLoadedMetadata:ReadonlySignal<EventListener>;
  @:html('onloadstart') final ?onLoadStart:ReadonlySignal<EventListener>;
  @:html('onmousedown') final ?onMouseDown:ReadonlySignal<EventListener>;
  @:html('onmouseenter') final ?onMouseEnter:ReadonlySignal<EventListener>;
  @:html('onmouseleave') final ?onMouseLeave:ReadonlySignal<EventListener>;
  @:html('onmousemove') final ?onMouseMove:ReadonlySignal<EventListener>;
  @:html('onmouseout') final ?onMouseOut:ReadonlySignal<EventListener>;
  @:html('onmouseover') final ?onMouseover:ReadonlySignal<EventListener>;
  @:html('onmouseup') final ?onMouseUp:ReadonlySignal<EventListener>;
  @:html('onpause') final ?onPause:ReadonlySignal<EventListener>;
  @:html('onplay') final ?onPlay:ReadonlySignal<EventListener>;
  @:html('onplaying') final ?onPlaying:ReadonlySignal<EventListener>;
  @:html('onprogress') final ?onProgress:ReadonlySignal<EventListener>;
  @:html('onratechange') final ?onRateChange:ReadonlySignal<EventListener>;
  @:html('onreset') final ?onReset:ReadonlySignal<EventListener>;
  @:html('onresize') final ?onResize:ReadonlySignal<EventListener>;
  @:html('onscroll') final ?onScroll:ReadonlySignal<EventListener>;
  @:html('onseeked') final ?onSeeked:ReadonlySignal<EventListener>;
  @:html('onseeking') final ?onSeeking:ReadonlySignal<EventListener>;
  @:html('onselect') final ?onSelect:ReadonlySignal<EventListener>;
  @:html('onshow') final ?onShow:ReadonlySignal<EventListener>;
  @:html('onstalled') final ?onStalled:ReadonlySignal<EventListener>;
  @:html('onsubmit') final ?onSubmit:ReadonlySignal<EventListener>;
  @:html('onsuspend') final ?onSuspend:ReadonlySignal<EventListener>;
  @:html('ontimeupdate') final ?onTimeEpdate:ReadonlySignal<EventListener>;
  @:html('onvolumechange') final ?onVolumeChange:ReadonlySignal<EventListener>;
  @:html('onwaiting') final ?onWaiting:ReadonlySignal<EventListener>;
  @:html('onpointercancel') final ?onPointerCancel:ReadonlySignal<EventListener>;
  @:html('onpointerdown') final ?onPointerDown:ReadonlySignal<EventListener>;
  @:html('onpointerup') final ?onPointerUp:ReadonlySignal<EventListener>;
  @:html('onpointermove') final ?onPointerMove:ReadonlySignal<EventListener>;
  @:html('onpointerout') final ?onPointerOut:ReadonlySignal<EventListener>;
  @:html('onpointerover') final ?onPointerOver:ReadonlySignal<EventListener>;
  @:html('onpointerenter') final ?onPointerEnter:ReadonlySignal<EventListener>;
  @:html('onpointerleave') final ?onPointerLeave:ReadonlySignal<EventListener>;
  @:html('ongotpointercapture') final ?onGotPointerCapture:ReadonlySignal<EventListener>;
  @:html('onlostpointercapture') final ?onLostPointerCapture:ReadonlySignal<EventListener>;
  @:html('onfullscreenchange') final ?onFullScreenChange:ReadonlySignal<EventListener>;
  @:html('onfullscreenerror') final ?onFullScreenError:ReadonlySignal<EventListener>;
  @:html('onpointerlockchange') final ?onPointerLockChange:ReadonlySignal<EventListener>;
  @:html('onpointerlockerror') final ?onPointerLockError:ReadonlySignal<EventListener>;
  @:html('onerror') final ?onError:ReadonlySignal<EventListener>;
  @:html('ontouchstart') final ?onTouchStart:ReadonlySignal<EventListener>;
  @:html('ontouchend') final ?onTouchEnd:ReadonlySignal<EventListener>;
  @:html('ontouchmove') final ?onTouchMove:ReadonlySignal<EventListener>;
  @:html('ontouchcancel') final ?onTouchCancel:ReadonlySignal<EventListener>;
}
