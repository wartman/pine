import Breeze;
import pine.Component;
import pine.html.Html;
import pine.signal.Signal;

function style(builder:Html, cls:ReadOnlySignal<ClassName>) {
  return builder.attr('class', cls);
}

function withStyle<T:Component<Html>>(component:T, cls):T {
  return component.addPlugin(builder -> style(builder, cls));
}
