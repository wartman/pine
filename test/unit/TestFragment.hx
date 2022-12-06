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

  // @todo: What we really need to test is the dang hydration.
}
