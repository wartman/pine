package pine.bridge;

using Kit;

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
    trace(html);
    return Nothing;
  }
}
