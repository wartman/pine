package unit;

import pine.ObservableObject;

using Medic;

// @todo: Real tests, basically.
class TestObservableObject implements TestCase {
  public function new() {}

  @:test
  function basicFunctionality() {
    var obs = new ObservableObject<{foo:String, bar:Int}>({foo: 'foo', bar: 1});
    var expected = 'foo1';
    obs.bind(data -> expected.equals(data.foo + data.bar));
    expected = 'bar1';
    obs.foo = 'bar';
    expected = 'bar2';
    obs.bar = 2;
  }
}
