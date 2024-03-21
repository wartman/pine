package pine.bridge;

@:structInit
class ClientConfig implements Disposable {
  public final main:String = 'BuildIslands';
  public final sources:Array<String> = [];
  public final temporaryDirectory:String = 'temp';
  public final outputDirectory:String = 'dist/www';
  public final outputName:String = 'app.js';
  public final libraries:Array<String> = [];
  public final flags:Array<String> = [];

  public function dispose() {}
}
