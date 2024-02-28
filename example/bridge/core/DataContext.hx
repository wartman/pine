package bridge.core;

import haxe.Json;
import kit.file.*;
import pine.Disposable;

using Kit;
using haxe.io.Path;

class DataContext implements Disposable {
  final source:Directory;

  public function new(source) {
    this.source = source;
  }

  public function getPost(id:String):Task<Post> {
    var path = Path.join([ 'posts', id ]).withExtension('json');
    return source.file(path)
      .read()
      .next(content -> Task.resolve(Json.parse(content)))
      .next(data -> Post.fromJson(data));
  }

  public function dispose() {}
}
