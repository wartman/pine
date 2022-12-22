package unit.state;

import pine.state.*;

using Medic;

class TestTrackedObject implements TestCase {
  public function new() {}

  @:test('Simple tracked object behavior works')
  public function testSimpleObject() {
    var obj = new TrackedObject<{foo:String}>({ foo: 'foo' });
    var expected = 'foo';
    var tests = 0;
    
    Observer.track(() -> {
      tests++;
      obj.foo.equals(expected);
    });
    
    expected = 'bar';
    obj.foo = 'bar';

    tests.equals(2);
  }

  @:test('Arrays are automatically made into TrackedArrays')
  public function testAutoArray() {
    var obj = new TrackedObject<{ foos:Array<String> }>({ foos: [] });
    var expected = 0;
    var tests = 0;

    Observer.track(() -> {
      tests++;
      obj.foos.length.equals(expected);
    });

    expected = 2;
    Action.run(() -> {
      obj.foos.push('one');
      obj.foos.push('two');
    });

    tests.equals(2);
  }

  @:test('Ugly workaround works for tracked object generics')
  public function testGenerics() {
    var foo = new WithGenerics<String>({ bar: 'ok' });
    foo.bar.equals('ok');
  }
}

typedef WithGenerics<T> = TrackedObject<{ bar: T }, 'T'>;
