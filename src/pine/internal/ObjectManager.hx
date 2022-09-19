package pine.internal;

interface ObjectManager extends Disposable {
  public function get():Dynamic;
  public function findParentObject():Dynamic;
}
