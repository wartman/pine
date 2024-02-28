package pine.bridge;

import kit.file.adaptor.*;
import kit.file.*;

using Kit;
using haxe.io.Path;
using pine.bridge.cli.CommandTools;

class IslandAsset implements Asset {
  static macro function getCurrentClassPaths();

  final config:ClientConfig;
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
    // return outputMainFile();
    return outputMainFile().next(_ -> runHaxeCommand());
  }

  function outputMainFile() {
    var path = config.main.withExtension('hx');
    var fs = new FileSystem(new SysAdaptor(Sys.getCwd()));

    return fs.directory(config.outputDirectory)
      .create()
      .next(dir -> dir.file(path).write(createMainHaxeFunction()));
  }

  function runHaxeCommand():Task<Nothing> {
    var path = createHaxeCommand();
    return switch Sys.command(path) {
      case 0: Nothing;
      case _: new Error(InternalError, 'Failed to generate haxe file');
    }
  }

  function createHaxeCommand() {
    // var paths:Array<String> = getCurrentClassPaths();
    var paths:Array<String> = [];
    var cmd = [ 'haxe'.createNodeCommand() ];
    var libraries = config.libraries ?? [];
    var flags = config.flags ?? [];

    if (!libraries.contains('pine')) {
      libraries.push('pine');
    }

    for (lib in libraries) {
      cmd.push('-lib $lib');
    }

    cmd.push(config.hxml.withExtension('hxml'));

    if (config.sources != null) {
      paths = paths.concat(config.sources);
    }

    paths.push(config.outputDirectory);

    for (path in paths) {
      cmd.push('-cp $path');
    }

    #if debug
    cmd.push('--debug');
    #end

    for (flag in flags) {
      cmd.push(flag);
    }
    
    cmd.push('-D pine.client');
    cmd.push('-main ${getMainName()}');
    cmd.push('-js ${getTarget()}');

    trace(cmd.join(' '));

    return cmd.join(' ');
  }

  function getTarget() {
    // @todo: Include version with app name.
    return Path.join([ config.outputDirectory, config.outputName ]).withExtension('js');
  }

  function getMainName() {
    return config.main?.withoutExtension() ?? 'Island';
  }

  function createMainHaxeFunction() {
    var buf = new StringBuf();
    buf.add('function main() {\n');
    buf.add('  var adaptor = new pine.html.client.ClientAdaptor();\n');
    for (island in islands.getIslandPaths()) {
      buf.add('  $island.hydrateIslands(adaptor);\n');
    }
    buf.add('}\n');
    return buf.toString();
  }
  #end
}
