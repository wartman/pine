package pine;

import pine.view.UntrackedProxyView;

@:autoBuild(pine.ComponentBuilder.build())
abstract class Component<Result:ViewBuilder = ViewBuilder> implements ViewBuilder {
  var plugins:Array<(builder:Result)->Result> = [];

  public function addPlugin<T:Component<Result>>(plugin:(builder:Result)->Result):T {
    plugins.push(plugin);
    return cast this;
  }

  abstract public function render(context:Context):Result;

  public function createView(parent:View, slot:Null<Slot>):View {
    var renderCallback = this.render;

    if (plugins.length > 0) {
      var mainRender = renderCallback;
      renderCallback = (context:Context) -> {
        var builder = mainRender(context);
        for (plugin in plugins) builder = plugin(builder);
        return builder;
      }
    }

    return new UntrackedProxyView(parent, parent.adaptor, slot, renderCallback);
  }
}
