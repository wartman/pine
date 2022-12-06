package unit.state;

import pine.state.*;
import pine.core.*;

using Medic;

class TestObserver implements TestCase {
  public function new() {}

  @:test('Observers work')
  function testSimple() {
    var value = new Atom(1);
    var expected = 1;
    var tests = 0;

    Observer.track(() -> {
      tests++;
      value.get().equals(expected);
    });

    expected = 2;
    value.set(2);
    tests.equals(2);
  }

  @:test('Cycles are caught')
  function testCycles() {
    var value = new Atom(0, (_, _) -> true);
    try {
      var i = 0;
      Observer.track(() -> {
        if (i++ > 10) {
          Assert.fail('Did not catch cycles');
          return;
        }
        value.get();
        value.set(0);
      });
    } catch (e:PineException) {
      Assert.pass();
    } catch (e) {
      Assert.fail('Unexpected exception');
    }
  }

  // @todo: more :P
}
