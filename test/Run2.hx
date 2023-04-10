import haxe.Timer;
import pine2.*;
import pine2.html.*;
import pine2.html.client.Client;
import pine2.signal.Observer;
import pine2.signal.Signal;

function main() {
  var value = new Signal('foo');
  var obj = new HtmlElementObject('main', {});
  mount(obj, () -> new Example(value));
}

class Example extends ProxyComponent {
  final value:Signal<String>;

  public function new(value) {
    this.value = value;
  }

  function build():Component {
    return new Html<'div'>({
      id: 'wrapper',
      className: compute(() -> 'example ' + value()),
      children: [
        'This is before the span. ',
        new Html<'span'>({
          children: [
            new Text('Before [ '),
            value,
            new Text(' ] After'),
          ]
        }),
        new Html<'input'>({
          value: value,
          oninput: e -> {
            var input:js.html.InputElement = cast e.target;
            value.set(input.value);
          }
        })
      ]
    });
  }
}
