package pine;

class Isolate extends ObserverComponent {
  @prop final wrap:(context:Context) -> Component;

  public function render(context:Context):Component {
    return wrap(context);
  }
}
