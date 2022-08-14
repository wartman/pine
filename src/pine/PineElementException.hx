package pine;

using pine.debug.DebugTools;

// @todo: Make this more useful.
class PineElementException extends PineException {
  public final element:Element;

  public function new(element:Element, message) {
    super([
      message,
      'In element tree:',
      element.locateElementInTree().toString()
    ].join('\n'));
    this.element = element;
  }
}
