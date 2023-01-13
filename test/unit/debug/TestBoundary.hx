package unit.debug;

import pine.Scope;
import haxe.ds.Option;
import pine.state.Signal;
import pine.html.HtmlChild;
import pine.debug.Boundary;

using Medic;
using medic.PineAssert;

class TestBoundary implements TestCase {
  public function new() {}

  @:test('Boundaries catch exceptions')
  @:test.async
  public function testSimpleBoundary(done) {
    new Boundary({
      render: context -> throw 'expected',
      caught: e -> (e.message:HtmlChild)
    }).rendersNext((element, defer) -> {
      defer(() -> {
        (element.getObject().toString():String).equals('expected');
        done();
      });
    });
  }

  @:test('Catches async errors')
  @:test.async
  public function testComplexBoundary(done) {
    var trigger = new Signal<Option<String>>(Some('foo'));
    new Boundary({
      render: context -> new Scope({
        render: context -> switch trigger.get() {
          case None: throw 'exception';
          case Some(value): (value:HtmlChild);
        }
      }),
      caught: e -> (e.message:HtmlChild)
    }).rendersNext((element, defer) -> {
        (element.getObject().toString():String).equals('foo');
        trigger.set(None);
        // @todo: This way of testing things is not going to work. 
        defer(() -> {
          (element.getObject().toString():String).equals('exception');
          done();
        });
    });
  }
}
