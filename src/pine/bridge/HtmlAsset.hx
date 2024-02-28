package pine.bridge;

using Kit;
using haxe.io.Path;

class HtmlAsset implements Asset {
  final path:String;
  final html:String;

  public function new(path, html) {
    this.path = path;
    this.html = html;
  }

  public function getIdentifier():Null<String> {
    return '__pine.html<${path}>';
  }

  public function process(context:AssetContext):Task<Nothing> {
    var url = Path.join([ path, 'index.html' ]);
    var file = context.output.file(url);
    return file.write(html);
  }
}
