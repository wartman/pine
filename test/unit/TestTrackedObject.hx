package unit;

import pine.*;

using Medic;
using medic.PineAssert;

class TestTrackedObject implements TestCase {
  public function new() {}

  @:test('Simple tracked object behavior works')
  @:test.async
  public function testSimpleObject(done) {
    var obj = new TrackedObject<{foo:String}>({ foo: 'foo' });
    var expected = 'foo';

    (done -> {
      obj.foo.equals(expected);
      if (expected == 'bar') done();
    }).asTracked(done);

    expected = 'bar';
    obj.foo = 'bar';
  }

  @:test('Arrays are automatically made into TrackedArrays')
  @:test.async
  public function testAutoArray(done) {
    var obj = new TrackedObject<{ foos:Array<String> }>({ foos: [] });
    var expected = 0;

    (done -> {
      obj.foos.length.equals(expected);
      if (expected == 2) done();
    }).asTracked(done);

    expected = 2;
    obj.foos.push('one');
    obj.foos.push('two');
  }
}
