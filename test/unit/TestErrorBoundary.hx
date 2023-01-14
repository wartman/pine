package unit;

import haxe.Timer;
import haxe.Exception;
import pine.html.*;
import pine.*;

using Medic;
using medic.PineAssert;

class TestErrorBoundary implements TestCase {
  public function new() {}

  @:test('Catches errors')
  function testErrorCatching() {
    new ErrorBoundary({
      render: context -> new Throws({}),
      fallback: thrown -> ((thrown.object:Exception).message:HtmlChild)
    }).renders('oh noes');
  }

  @:test('Can recover')
  @:test.async
  function testRecover(done) {
    var component = new Throws({});
    new ErrorBoundary({
      render: context -> component,
      fallback: thrown -> ((thrown.object:Exception).message:HtmlChild),
      recover: (_, next) -> {
        Timer.delay(() -> {
          component.shouldThrow = false;
          next();
        }, 0);
      }
    }).rendersNext((element, defer) -> {
      (element.getObject().toString():String).equals('oh noes');
      defer(() -> {
        (element.getObject().toString():String).equals('ok');
        done();
      });
    });
  }

  @:test('Can recover a nested component')
  @:test.async
  function testRecoverNested(done) {
    var component = new ThrowsWithNesting({});
    new ErrorBoundary({
      render: context -> component,
      fallback: thrown -> ((thrown.object:Exception).message:HtmlChild),
      recover: (_, next) -> {
        Timer.delay(() -> {
          component.shouldThrow = false;
          next();
        }, 0);
      }
    }).rendersNext((element, defer) -> {
      (element.getObject().toString():String).equals('oh noes');
      defer(() -> {
        (element.getObject().toString():String).equals('<div>foo ok</div>');
        done();
      });
    });
  }

  // @todo: Test to make sure that the failedBranch retains state
}

class Throws extends AutoComponent {
  public var shouldThrow:Bool = true;

  public function render(context:Context):Component {
    if (shouldThrow) throw 'oh noes';
    return ('ok':HtmlChild);
  }
}

class ThrowsWithNesting extends AutoComponent {
  public var shouldThrow:Bool = true;

  function render(context:Context) {
    return new Html<'div'>({
      children: [
        'foo ',
        new Throws({ shouldThrow: shouldThrow })
      ]
    });
  }
}
