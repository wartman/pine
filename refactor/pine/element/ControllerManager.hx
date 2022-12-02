package pine.element;

final class ControllerManager  {
  final controllers:Array<Controller<Dynamic>> = [];

  public function new(controllers) {
    this.controllers = controllers;
  }
  
  public function init<T:Component>(element:ElementOf<T>) {
    for (controller in controllers) {
      controller.register(element);
      element.addDisposable(controller);
    }
  }
}
