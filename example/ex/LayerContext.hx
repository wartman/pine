package ex;

enum LayerContextStatus {
  Showing;
  Hiding;
}

class LayerContext extends Model {
  public static function from(context:View) {
    return context.get(LayerContext)
      .toMaybe()
      .orThrow('No layer context found');
  }
  
  @:signal public final status:LayerContextStatus = Showing;

  public function hide():Void {
    status.set(Hiding);
  }
  
  public function show():Void {
    status.set(Showing);
  }
}
