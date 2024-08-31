package site.data;

import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;
import pine.debug.Debug;

@:fallback(error('No filesystem context found'))
class FileSystemContext implements Context {
	public final fs:FileSystem;

	public function new(root:String) {
		this.fs = new FileSystem(new SysAdaptor(root));
	}

	public function dispose() {}
}
