package pine.bridge;

class IslandContext implements Disposable {
  final islands:Array<String> = [];

  public function new() {}

  public function getIslandPaths():Array<String> {
    return islands;
  }

  public function registerIsland(islandPath:String) {
    if (!islands.contains(islandPath)) {
      islands.push(islandPath);
    }
  }

  public function dispose() {
    islands.resize(0);
  }
}
