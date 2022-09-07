package unit;

import pine.*;

using Medic;
using medic.PineAssert;

class TestComputation implements TestCase {
  public function new() {}

  @:test
  function computationWorks() {
    var foo = new State(1);
    var bar = new State(1);
    var expected = 2;
    var tests = 0;
    var computation = new Computation(() -> {
      tests++;
      return foo.get() + bar.get();
    });

    Observer.track(() -> {
      computation.get().equals(expected);
    });

    expected = 4;

    Action.run(() -> {
      foo.set(2);
      bar.set(2);
    });

    tests.equals(2);
  }
}
