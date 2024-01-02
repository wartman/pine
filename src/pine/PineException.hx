package pine;

import haxe.Exception;

using Type;

class PineException extends Exception {}

class PineComponentException extends PineException {
  public function new(message) {
    super(message);
  }
}
