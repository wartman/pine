package pine.bridge;

import kit.file.Directory;

using Kit;
using Lambda;
using haxe.io.Path;

class AppContext implements Disposable {
  public static function from(context:View) {
    return context.get(AppContext).toMaybe().orThrow('No app context found');
  }

  public final config:ClientConfig;
  public final output:Directory;
  final assets:Array<Asset> = [];

  public function new(config, output, ?document) {
    this.config = config;
    this.output = output;
  }

  public function getClientAppPath() {
    return config.outputName.withExtension('js').normalize();
  }

  public function addAsset(asset:Asset) {
    var id = asset.getIdentifier();
    if (id != null && assets.exists(asset -> asset.getIdentifier() == id)) {
      return;
    }
    if (!assets.contains(asset)) {
      assets.push(asset);
    }
  }

  public function process() {
    return Task.parallel(...assets.map(asset -> asset.process(this)));
  }

  public function dispose() {}
}
