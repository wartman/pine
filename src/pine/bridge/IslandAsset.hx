package pine.bridge;

using Kit;
using haxe.io.Path;

class IslandAsset implements Asset {
  static macro function getCurrentClassPaths();

  final config:IslandConfig;
  final islands:IslandContext;

  public function new(config, islands) {
    this.config = config;
    this.islands = islands;
  }

  public function getIdentifier() {
    return '__pine.island-asset';
  }

  #if pine.client
  public function process(context:AssetContext):Task<Nothing> {
    return null;
  }
  #else
  public function process(context:AssetContext):Task<Nothing> {
    trace(createMainHaxeFunction());
    trace(createHaxeCommand());
    return Nothing;
  }

  function createHaxeCommand() {
    var paths:Array<String> = getCurrentClassPaths();
    var parts = [ 'haxe' ];
    var libraries = config.libraries ?? [];

    if (!libraries.contains('pine')) {
      libraries.push('pine');
    }

    if (!libraries.contains('kit')) {
      libraries.push('kit');
    }

    for (lib in libraries) {
      parts.push('--library $lib');
    }

    if (config.sources != null) {
      paths = paths.concat(config.sources);
    }

    for (path in paths) {
      parts.push('--class-path $path');
    }
    
    parts.push('--main ${getMainName()}');
    parts.push('--js ${getTarget()}');

    return parts.join(' ');
  }

  function getTarget() {
    // @todo: Include version with app name.
    return (config?.target ?? 'app.js').withExtension('js');
  }

  function getMainName() {
    return config.main?.withoutExtension() ?? 'Island';
  }

  function createMainHaxeFunction() {
    var buf = new StringBuf();
    buf.add('function main() {\n');
    // @todo: figure out a better root
    buf.add('  var target = js.Browser.document.createTextNode("");\n');
    buf.add('  js.Browser.document.body.append(target);\n');
    buf.add('  var root = pine.html.client.ClientRoot.hydrate(target, () -> pine.Placeholder.build());\n');
    for (island in islands.getIslandPaths()) {
      buf.add('  $island.hydrateIslands(root);\n');
    }
    buf.add('}\n');
    return buf.toString();
  }
  #end
}
