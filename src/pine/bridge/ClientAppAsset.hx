package pine.bridge;

import kit.file.adaptor.*;
import kit.file.*;

using haxe.io.Path;
using pine.bridge.cli.CommandTools;

class ClientAppAsset implements Asset {
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
	public function process(context:AppContext):Task<Nothing> {
		return null;
	}
	#else
	public function process(context:AppContext):Task<Nothing> {
		return outputMainFile().next(_ -> runHaxeCommand());
	}

	function outputMainFile() {
		var path = config.main.withExtension('hx');
		var fs = new FileSystem(new SysAdaptor(Sys.getCwd()));

		return fs.directory(config.temporaryDirectory)
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
		// @todo: This *should* capture all our dependencies, but I've only
		// tested it with Lix, so who really knows.
		var paths:Array<String> = getCurrentClassPaths().filter(path -> path != '' && path != null);
		var cmd = ['haxe'.createNodeCommand()];
		var libraries = config.libraries ?? [];
		var flags = config.flags ?? [];

		// if (!libraries.contains('pine')) {
		//   libraries.push('pine');
		// }

		for (lib in libraries) {
			cmd.push('-lib $lib');
		}

		// cmd.push(config.hxml.withExtension('hxml'));

		if (config.sources.length > 0) {
			paths = paths.concat(config.sources);
		}

		paths.push(config.temporaryDirectory);

		for (path in paths) {
			cmd.push('-cp $path');
		}

		cmd.push('-D js-es=6');
		cmd.push('-D message-reporting=pretty');

		#if debug
		cmd.push('--debug');
		#else
		cmd.push('--dce full');
		cmd.push('-D analyzer-optimize');
		#end

		for (flag in flags) {
			cmd.push(flag);
		}

		cmd.push('-D pine.client');
		cmd.push('-main ${getMainName()}');
		cmd.push('-js ${getTarget()}');

		return cmd.join(' ');
	}

	function getTarget() {
		// @todo: Include version with app name.
		return Path.join([config.outputDirectory, config.outputName]).withExtension('js');
	}

	function getMainName() {
		return config.main?.withoutExtension() ?? 'Island';
	}

	function createMainHaxeFunction() {
		var buf = new StringBuf();
		buf.add('function main() {\n');
		buf.add('  hydrateIslands();\n');
		// @todo: add code that allows HTML swapping.
		buf.add('}\n\n');
		buf.add('private function hydrateIslands() {\n');
		buf.add('  var adaptor = new pine.html.client.ClientAdaptor();\n');
		for (island in islands.getIslandPaths()) {
			buf.add('  $island.hydrateIslands(adaptor);\n');
		}
		buf.add('}\n');
		return buf.toString();
	}
	#end
}
