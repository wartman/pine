package unit.core;

import pine.core.*;

using Medic;

class TestHasLazyProps implements TestCase {
  public function new() {}

  @:test('Basic functionality works')
  public function testBasics() {
    var lazy = new LazyWorks('foo');
    lazy.fooBar.equals('foobar');
  }
}

class LazyWorks implements HasLazyProps {
  public final foo:String;
  @:lazy public final fooBar:String = foo + 'bar';

  public function new(foo) {
    this.foo = foo;
  }
}
