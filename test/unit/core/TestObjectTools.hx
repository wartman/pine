package unit.core;

using Medic;
using Reflect;
using pine.core.ObjectTools;

class TestObjectTools implements TestCase {
  public function new() {}

  @:test('Diffs objects and does not run on matching values')
  function testSimpleDiffing() {
    var a = { a: 'a', b: 'b' };
    var called = 0;
    
    a.diff({ a: 'a', b: 'new' }, (key, old, nu) -> {
      called++;
      a.setField(key, nu);
    });
    
    called.equals(1);
    a.fields().length.equals(2);
    (a.field('a'):Null<String>).equals('a');
    (a.field('b'):Null<String>).equals('new');
  }

  @:test('Merge will create a new object combining two inputs')
  function testMerge() {
    var a = { a: 'a', b: 'b' };
    
    var c = a.merge({ a: 'a', b: 'new' });

    c.fields().length.equals(2);
    (c.field('a'):Null<String>).equals('a');
    (c.field('b'):Null<String>).equals('new');

    var d = c.merge({ a: 'a', b: null });

    d.fields().length.equals(1);
    (d.field('a'):Null<String>).equals('a');
    (d.field('b'):Null<String>).equals(null);

    var d = c.merge({ a: 'a', b: 'foo', c: 'c' });

    d.fields().length.equals(3);
    (d.field('a'):Null<String>).equals('a');
    (d.field('b'):Null<String>).equals('foo');
    (d.field('c'):Null<String>).equals('c');
  }
}
