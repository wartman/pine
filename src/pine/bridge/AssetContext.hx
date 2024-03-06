package pine.bridge;

import kit.file.Directory;
import Kit.Task;

using Lambda;

class AssetContext implements Disposable {
  public final config:ClientConfig;
  public final output:Directory;
  final assets:Array<Asset> = [];

  public function new(config, output) {
    this.config = config;
    this.output = output;
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
