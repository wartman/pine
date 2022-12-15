package unit.core;

import pine.core.*;

using Medic;

class TestHasAutoConstructor implements TestCase {
  public function new() {}

  @:test('HasAutoConstructor will automatically create a constructor, like its name implies')
  function testBasics() {
    var auto = new AutoOne({ one: 'one', two: 2 });
    auto.one.equals('one');
    auto.two.equals(2);
  }

  @:test('HasAutoConstructor understands @:skip')
  function testSkip() {
    var auto = new AutoWithSkip({ one: 'one' });
    auto.one.equals('one');
    auto.two.equals(2);
  }

  @:test('Works with HasLazyProps')
  function testInterop() {
    var lazy = new AutoWorksWithLazy({ one: 'one' });
    lazy.two.equals('onetwo');
  }
}

class AutoOne implements HasAutoConstructor {
  public final one:String;
  public final two:Int; 
}

class AutoWithSkip implements HasAutoConstructor {
  public final one:String;
  @:skip public final two:Int = 2; 
}

class AutoWorksWithLazy
  implements HasAutoConstructor
  implements HasLazyProps
{
  public final one:String;
  @:lazy public final two:String = one + 'two';
}
