package unit;

import pine.*;
import pine.html.*;
import pine.html.server.*;

using Medic;
using medic.PineAssert;
using pine.core.OptionTools;

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
      children: [ ('a':HtmlChild), ('b':HtmlChild), ('c':HtmlChild), ('d':HtmlChild) ]
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
        ('a':HtmlChild),
        new Fragment({
          children: [
            ('frag:b':HtmlChild),
            ('frag:c':HtmlChild)
          ]
        }),
        ('d':HtmlChild)
      ]
    }).hydrates(doc);
  }

  @:test('Fragments keep the right order')
  @:test.async
  function testOrdering(done) {
    var fragment = new Fragment({
      children: [ 
        ('a':HtmlChild),
        ('b':HtmlChild),
        new Fragment({
          children: [
            ('c':HtmlChild), 
            ('d':HtmlChild)
          ]
        }),
        ('e':HtmlChild),
      ]
    });
    fragment.rendersAsync(root -> {
      root.toString().equals('abcde');
      root.queryChildren().findOfType(Fragment).sure().update(new Fragment({
        children: [
          ('a':HtmlChild),
          ('c':HtmlChild),
          new Fragment({
            children: [
              ('d':HtmlChild),
              ('b':HtmlChild), 
            ]
          }),
          ('e':HtmlChild),
        ]
      }));
      root.getAdaptor().afterRebuild(() -> {
        root.toString().equals('acdbe');
        root.queryChildren().findOfType(Fragment).sure().update(new Fragment({
          children: [
            ('a':HtmlChild),
            new Fragment({
              children: [
                ('d':HtmlChild),
                ('b':HtmlChild), 
              ]
            }),
            ('c':HtmlChild),
            ('e':HtmlChild),
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
