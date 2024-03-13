package site.data;

import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;

class FileSystemContext implements Disposable {
  public static function from(context:View) {
    return context.get(FileSystemContext)
      .toMaybe()
      .orThrow('No FileSystem available');
  }

  public final fs:FileSystem;

  public function new(root:String) {
    this.fs = new FileSystem(new SysAdaptor(root));
  }

  public function dispose() {} 
}
