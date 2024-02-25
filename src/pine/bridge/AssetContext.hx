package pine.bridge;

import pine.bridge.Bridge;
import Kit.Task;

using Lambda;

class AssetContext implements Disposable {
  public final config:ClientConfig;
  final assets:Array<Asset> = [];

  public function new(config) {
    this.config = config;
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

  public function dispose() {
    
  }

  public function process() {
    return Task.parallel(...assets.map(asset -> asset.process(this)));
  }
}
