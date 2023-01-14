package pine.debug.html;

import haxe.Exception;
import pine.html.*;
import pine.ErrorBoundary;

function formatError(thrown:ThrownObject) {
  if (thrown.object is Exception) {
    var e:Exception = thrown.object;
    // @todo
    // Then display where in the Element chain
    // the error happened.
  }
}

class WrapError extends AutoComponent {
  final child:HtmlChild;

  public function render(context:Context):Component {
    return new ErrorBoundary({
      render: _ -> child,
      fallback: thrown -> {
        null;
      }
    });
  }
}
