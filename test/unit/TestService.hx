package unit;

import impl.*;
import pine.*;

using Medic;
using medic.PineAssert;

class TestService implements TestCase {
  public function new() {}

  @:test('Falls back to default')
  @:test.async
  function testFallback(done) {
    var foo = new FooServiceTester({});
    foo.renders('foo', done);
  }

  @:test('Has a shortcut for providing values')
  @:test.async
  function testProvide(done) {
    FooService.provide(
      () -> new FooService('bar'),
      _ -> new FooServiceTester({})
    ).renders('bar', done);
  }
}

@default(new FooService('foo'))
class FooService implements Service {
  public final foo:String;

  public function new(foo) {
    this.foo = foo;
  }

  public function dispose() {}
}

class FooServiceTester extends ImmutableComponent {
  function render(context:Context) {
    return new TextComponent({
      content: FooService.from(context).foo
    });
  }
}
