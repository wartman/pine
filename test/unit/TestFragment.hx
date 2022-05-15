package unit;

import pine.Component;
import pine.Fragment;
import impl.*;

using Medic;
using medic.PineAssert;

function text(content:String) {
  return new TextComponent({content: content});
}

function fragment(...children:Component) {
  return new Fragment({children: children.toArray()});
}

class TestFragment implements TestCase {
  public function new() {}

  @:test('Empty fragments work')
  @:test.async
  function testEmpty(done) {
    fragment().renders('', done);
  }

  @:test('Fragments work')
  @:test.async
  function simpleFragments(done) {
    fragment(text('a'), text('b'), text('c'), text('d')).renders('a b c d', done);
  }

  @:test('Fragments will render relative to the elements around them')
  @:test.async
  function fragmentsInContext(done) {
    fragment(text('a'), fragment(text('b.1'), text('b.2')), text('c')).renders('a b.1 b.2 c', done);
  }

  @:test('Empty fragments render relative to the elements around them')
  @:test.async
  function testEmptyInContext(done) {
    fragment(text('before'), fragment(), text('after')).renders('before <marker> after', done);
  }

  // @todo: Test re-rendering of Fragments
}
