package unit;

import pine.*;

using Medic;
using medic.PineAssert;

class TestObserver implements TestCase {
  public function new() {}

  @:test('Observers work')
  @:test.async
  function testSimple(done) {
    var value = new State(1);
    var expected = 1;
    
    (done -> {
      value.get().equals(expected);
      if (expected == 2) done();
    }).asTracked(done);

    expected = 2;
    value.set(2);
  }

  // @todo: more :P
}
