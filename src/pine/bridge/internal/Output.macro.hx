package pine.bridge.internal;

import haxe.macro.Context;

var initialized = false;

function register(path:String) {
  
}

private function export() {
	if (initialized) return;

	initialized = true;
  
  Context.onAfterTyping(types -> {

	});
}

private function getExportFilename(path:Null<String>) {
	// return switch path {
	// 	case null:
	// 		Path.join([sys.FileSystem.absolutePath(Compiler.getOutput().directory()), 'styles']).withExtension('css');
	// 	case abs = _.charAt(0) => '.' | '/':
	// 		abs.withExtension('css');
	// 	case relative:
	// 		Path.join([sys.FileSystem.absolutePath(Compiler.getOutput().directory()), relative]).withExtension('css');
	// }
}

// private function ensureDir(path:String) {
// 	var directory = path.directory();
// 	if (!directory.exists()) {
// 		ensureDir(directory);
// 		directory.createDirectory();
// 	}
// 	return path;
// }
