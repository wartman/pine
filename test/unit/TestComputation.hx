package unit;

import pine.*;

using Medic;
using medic.PineAssert;

class TestComputation implements TestCase {
  public function new() {}

  @:test
  @:test.async
  function computationWorks(done) {
    var foo = new State(1);
    var bar = new State(1);
    var computation = new Computation(() -> {
      return foo.get() + bar.get();
    });
    var expected = 2;

    (done -> {
      computation.get().equals(expected);
      if (expected == 4) done();
    }).asTracked(done);

    expected = 4;
    foo.set(2);
    bar.set(2);
  }
}
