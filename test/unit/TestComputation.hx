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

    new Observer(() -> {
      computation.get().equals(expected);
    });

    expected = 4;

    new Action(() -> {
      foo.set(2);
      bar.set(2);
    }).trigger();

    tests.equals(2);
  }
}
