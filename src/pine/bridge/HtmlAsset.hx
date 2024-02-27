package pine.bridge;

using Kit;
using haxe.io.Path;

class HtmlAsset implements Asset {
  final path:String;
  final html:String;

  public function new(path, html) {
    this.path = path == '/' ? 'index' : path;
    this.html = html;
  }

  public function getIdentifier():Null<String> {
    return '__pine.html<${path}>';
  }

  public function process(context:AssetContext):Task<Nothing> {
    var file = context.output.file(path.withExtension('html'));
    return file.write(html);
  }
}
