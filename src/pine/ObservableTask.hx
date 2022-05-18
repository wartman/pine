package pine;

import pine.Observable.ObservableOptions;

@:forward
abstract ObservableTask<Data, Error>(Observable<Task<Data, Error>>) from Observable<Task<Data, Error>> {
  @:from
  public static function ofTask<Data, Error>(task:Task<Data, Error>) {
    return new ObservableTask(task);
  }

  @:from
  public static function ofArray<Data, Error>(tasks:Array<ObservableTask<Data, Error>>):ObservableTask<Array<Data>, Error> {
    var remaining = tasks.length;
    var content:Array<Data> = [];
    var failed:Bool = false;
    var completed:Bool = false;
    var observable = new ObservableTask(Suspended);

    if (remaining == 0) {
      observable.update(Ready(content));
      return observable;
    }

    for (task in tasks) {
      task.handle(res -> switch res {
        case Suspended:
          Pending;
        case Ready(_) if (failed):
          Handled;
        case Ready(data):
          content.push(data);
          --remaining;
          if (remaining <= 0) {
            Debug.assert(!failed);
            Debug.assert(!completed);
            completed = true;
            observable.update(Ready(content));
          }
          Handled;
        case Failed(_) if (failed):
          Handled;
        case Failed(error):
          failed = true;
          observable.update(Failed(error));
          Handled;
      });
    }
    return observable;
  }

  public static inline function await<Data, Error>(handler:(resume:(data:Data) -> Void, fail:(error:Error) -> Void) -> Void):ObservableTask<Data, Error> {
    var obs = new ObservableTask<Data, Error>(Suspended);
    handler(data -> obs.update(Ready(data)), err -> obs.update(Failed(err)));
    return obs;
  }

  public inline function new(task, ?options) {
    this = new Observable(task, options);
  }

  public function map<R>(transform:(task:Task<Data, Error>) -> Task<R, Error>, ?options) {
    return this.map(transform, options);
  }

  public function flatMap<R>(transform:(task:Task<Data, Error>) -> ObservableTask<R, Error>, ?options):ObservableTask<R, Error> {
    var observable = new ObservableTask(Suspended, options);
    this.handle(res -> switch res {
      case Suspended:
        Pending;
      default:
        transform(res).handle(res -> switch res {
          case Suspended:
            Pending;
          case Ready(data):
            observable.update(Ready(data));
            Handled;
          case Failed(error):
            observable.update(Failed(error));
            Handled;
        });
        Handled;
    });
    return observable;
  }

  public function then<R>(transform:(data:Data) -> R, ?recover:(error:Error) -> R, ?options:ObservableOptions<Task<R, Error>>):ObservableTask<R, Error> {
    if (options == null) {
      options = {};
    }
    return this.map(res -> switch res {
      case Suspended: Task.Suspended;
      case Failed(error) if (recover != null): Task.Ready(recover(error));
      case Failed(error): Task.Failed(error);
      case Ready(data): Task.Ready(transform(data));
    }, options);
  }

  public inline function pipe<R>(handler:(data:Data) -> ObservableTask<R, Error>, ?options):ObservableTask<R, Error> {
    return flatMap(res -> switch res {
      case Suspended: Task.Suspended;
      case Failed(error): Task.Failed(error);
      case Ready(data): handler(data);
    }, options);
  }
}
