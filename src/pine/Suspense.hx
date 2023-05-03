package pine;

import pine.signal.*;

using Kit;

enum SuspenseStatus<T, E> {
  Suspended;
  Active(result:Result<T, E>);
}

class Suspense<T, E> extends AutoComponent {
  final task:Task<T, E>;
  final child:(status:SuspenseStatus<T, E>)->Child;

  function build() {
    var status = new Signal<SuspenseStatus<T, E>>(Suspended);
    var link = task.handle(result -> status.set(Active(result)));

    addDisposable(() -> {
      SuspenseBoundary.markComplete(this);
      link.cancel();
    });
    addEffect(() -> {
      switch status() {
        case Suspended:
          SuspenseBoundary.track(this);
        case Active(_):
          SuspenseBoundary.markComplete(this);
      }
      null;
    });

    return new Scope(_ -> child(status()));
  }
}

enum SuspenseBoundaryStatus {
  Suspended(remaining:Array<Component>);
  Ready;
}

class SuspenseBoundary extends AutoComponent {
  public static function track(context:Component) {
    Observer.untrack(() -> {
      maybeFrom(context).ifExtract(Some(boundary), switch boundary.status.peek() {
        case Suspended(remaining) if (!remaining.contains(context)):
          boundary.status.set(Suspended(remaining.concat([ context ])));
        case Ready:
          boundary.status.set(Suspended([ context ]));
        default:
      });
    });
  }

  public static function markComplete(context:Component) {
    Observer.untrack(() -> {
      maybeFrom(context).ifExtract(Some(boundary), switch boundary.status.peek() {
        case Suspended(remaining) if (remaining.contains(context)):
          var remaining = remaining.filter(o -> o != context);
          if (remaining.length == 0) {
            boundary.status.set(Ready);  
          } else {
            boundary.status.set(Suspended(remaining));
          }
        default:
      });
    });
  }

  static function maybeFrom(context:Component) {
    return context.findAncestorOfType(SuspenseBoundary);
  }

  final child:Component;
  @:observable public final onComplete:()->Void;
  @:signal public final status:SuspenseBoundaryStatus = Ready;

  public function build():Component {
    addEffect(() -> {
      var complete = onComplete();
      return switch status() {
        case Ready:
          // @todo: Can we remove this timer?
          var timer = haxe.Timer.delay(() -> {
            switch status.peek() {
              case Suspended(_): return;
              default:
            }
            complete();
          }, 10);
          () -> {
            timer.stop();
            timer = null;
          }
        case Suspended(_):
          null;
      }
    });

    return child;
  }
}
