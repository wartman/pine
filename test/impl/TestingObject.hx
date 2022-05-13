package impl;

import pine.render.Object;

class TestingObject extends Object {
  public var content:String;

  public function new(content) {
    this.content = content;
  }

  public function toString() {
    return content + children.map(c -> c.toString()).join(' ');
  }
}
