package pine.bridge;

import pine.debug.Debug;
import kit.file.Directory;

using Lambda;
using haxe.io.Path;

@:fallback(error('No app context found'))
class AppContext implements Context {
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
