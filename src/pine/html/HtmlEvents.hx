package pine.html;

#if (js && !nodejs)
typedef Event = js.html.Event;
#else
typedef Event = Dynamic;
#end
typedef EventListener = (e:Event) -> Void;
