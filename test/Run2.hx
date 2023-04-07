import haxe.Timer;
import pine2.signal.Observer;
import pine2.signal.Signal;
import pine2.component.Box;
import pine2.*;
import pine2.html.server.HtmlElementObject;
import pine2.html.server.Server;

function main() {
  var value = new Signal('foo');
  var obj = new HtmlElementObject('div', {});
  var root = mount(obj, () -> new Example(value));

  var obs = new Observer(() -> trace('value: ' + value.get()));
  trace(obj.toString());

  Timer.delay(() -> {
    value.set('bar');
    trace(obj.toString());
  }, 200);
}

class Example extends ProxyComponent {
  final value:Signal<String>;

  public function new(value) {
    this.value = value;
  }

  function build():Component {
    return new Box({ className: 'foo' }, [
      new Text('Before [ '),
      new Text(value),
      new Text(' ] After'),
    ]);
  }
}
