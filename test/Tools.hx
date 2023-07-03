import pine.Disposable;
import pine.signal.Graph;

function createScope(cb:()->Void) {
  return () -> {
    var root = new DisposableCollection();
    withOwner(root, cb);
    root.dispose();
  }
}
