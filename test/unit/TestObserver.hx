package unit;

import pine.*;

using Medic;

class TestObserver implements TestCase {
  public function new() {}

  @:test('Observers work')
  function testSimple() {
    var value = new State(1);
    var expected = 1;
    var tests = 0;

    new Observer(() -> {
      tests++;
      value.get().equals(expected);
    });

    expected = 2;
    value.set(2);
    tests.equals(2);
  }

  // @todo: more :P
}
