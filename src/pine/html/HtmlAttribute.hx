package pine.html;

import haxe.ds.Either;
import pine.signal.Signal;

abstract HtmlAttribute<T>(Either<T, ReadonlySignal<T>>) {
  @:from public inline static function ofValue<T>(value:T):HtmlAttribute<T> {
    return new HtmlAttribute(Left(value));
  }

  @:from public inline static function ofReadonlySignal<T>(value:ReadonlySignal<T>):HtmlAttribute<T> {
    return new HtmlAttribute(Right(value));
  }

  @:from public inline static function ofSignal<T>(value:Signal<T>):HtmlAttribute<T> {
    return new HtmlAttribute(Right(value));
  }

  public inline function new(either) {
    this = either;
  }

  @:to public inline function unwrap():Either<T, ReadonlySignal<T>> {
    return this;
  }
}
