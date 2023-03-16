package unit;

import pine.*;
import pine.html.*;
import pine.html.server.*;

using Medic;
using medic.PineAssert;

class TestFragment implements TestCase {
  public function new() {}
  
  @:test('Empty fragments work')
  function testEmpty() {
    var fragment = new Fragment({ children: [] });
    fragment.renders('');
  }

  @:test('Fragments work')
  function testSimple() {
    var fragment = new Fragment({
      children: [ new Text('a'), new Text('b'), new Text('c'), new Text('d') ]
    });
    fragment.renders('abcd');
  }

  @:test('Fragments hydrate')
  function testHydration() {
    var doc = new HtmlElementObject('#document', {});
    var target = new HtmlElementObject('div', {});

    doc.append(target);

    target.append(new HtmlTextObject('a'));
    target.append(new HtmlTextObject('frag:b'));
    target.append(new HtmlTextObject('frag:c'));
    target.append(new HtmlTextObject('d'));

    new Html<'div'>({
      children: [
        new Text('a'),
        new Fragment({
          children: [
            new Text('frag:b'),
            new Text('frag:c')
          ]
        }),
        new Text('d')
      ]
    }).hydrates(doc);
  }

  @:test('Fragments keep the right order')
  @:test.async
  function testOrdering(done) {
    var fragment = new Fragment({
      children: [ 
        new Text('a'),
        new Text('b'),
        new Fragment({
          children: [
            new Text('c'), 
            new Text('d')
          ]
        }),
        new Text('e'),
      ]
    });
    fragment.rendersAsync(root -> {
      root.toString().equals('abcde');
      root.queryChildren().findOfType(Fragment).orThrow().update(new Fragment({
        children: [
          new Text('a'),
          new Text('c'),
          new Fragment({
            children: [
              new Text('d'),
              new Text('b'), 
            ]
          }),
          new Text('e'),
        ]
      }));
      root.getAdaptor().afterRebuild(() -> {
        root.toString().equals('acdbe');
        root.queryChildren().findOfType(Fragment).orThrow().update(new Fragment({
          children: [
            new Text('a'),
            new Fragment({
              children: [
                new Text('d'),
                new Text('b'), 
              ]
            }),
            new Text('c'),
            new Text('e'),
          ]
        }));
        root.getAdaptor().afterRebuild(() -> {
          root.toString().equals('adbce');
          done();
        });
      });
    });
  }
}
