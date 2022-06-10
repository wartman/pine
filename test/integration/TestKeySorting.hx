package integration;

import pine.*;
import impl.*;

using Medic;

class TestKeySorting implements TestCase {
  public function new() {}

  @:test
  @:test.async
  function testBasicKeySorting(done) {
    var boot = new TestingBootstrap();
    var root = boot.mount(new Fragment({
      children: [
        new TextComponent({content: 'a', key: 1}),
        new TextComponent({content: 'b', key: 2}),
        new TextComponent({content: 'c', key: 3})
      ],
      key: 'fragment'
    }));
    root.afterBuild.enqueue(done);
  }
}
