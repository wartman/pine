package pine;

class Effect implements Disposable implements DisposableHost {
  public static function from(context:InitContext) {
    return new Effect(context);
  }
  
  var isDisposed:Bool = false;
  final context:InitContext;
  final disposables:Array<Disposable> = [];
  
  public function new(context) {
    this.context = context;
    this.context.addDisposable(this);
  }
  
  public function add(effect:()->Void) {
    if (isDisposed) return;
    addDisposable(new Observer(effect));
  }
  
  public function addDisposable(disposable:Disposable) {
    disposables.push(disposable);
  }
  
  public function dispose() {
    if (isDisposed) return;
    isDisposed = true;
    for (disposable in disposables) disposable.dispose();
  }
}
