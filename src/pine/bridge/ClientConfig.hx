package pine.bridge;

@:structInit
class ClientConfig implements Disposable {
  public final hxml:String; 
  public final main:String = 'Island';
  public final sources:Array<String> = [ 'src' ];
  public final outputDirectory:String = 'temp';
  public final outputName:String = 'app.js';
  public final libraries:Array<String> = [];
  public final flags:Array<String> = [];

  public function dispose() {
    // noop
  }
}
