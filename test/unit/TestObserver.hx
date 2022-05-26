package unit;

import pine.*;

using Medic;

class TestObserver implements TestCase {
  public function new() {}

  @:test('Observers work')
  @:test.async
  function testSimple(done) {
    var value = new Signal(1);
    var expected = 1;
    
    new Observer(() -> {
      value.get().equals(expected);
      if (expected == 2) done();
    });

    expected = 2;
    value.set(2);
  }

  // @todo: more :P
}
