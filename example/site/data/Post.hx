package site.data;

import haxe.Json;
import kit.file.FileSystem;

using Kit;

class Post extends Model {
  public static function from(context:View) {
    return new PostBuilder(FileSystemContext.from(context).fs);
  }

  @:constant public final title:String;
  @:constant public final sort:Int;
  @:constant public final content:String;
}

class PostBuilder {
  public final fs:FileSystem;
  
  public function new(fs) {
    this.fs = fs;
  }

  public function fetch(id:Int):Task<Post> {
    return fs.directory('data')
      .file('post-$id.json')
      .read()
      .next(data -> Post.fromJson(Json.parse(data)));
  }
}
