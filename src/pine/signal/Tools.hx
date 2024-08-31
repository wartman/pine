package pine.signal;

import pine.For;
import pine.signal.Signal;

/**
	Wrap a ReadOnlySignal (which can be a Computation, Resource or Signal)
	in a Scope component, which will allow you to use it directly as
	a View.
**/
inline function scope<T>(source:ReadOnlySignal<T>, render:(value:T) -> Child) {
	return Scope.wrap(() -> render(source()));
}

inline function then(source:ReadOnlySignal<Bool>, render:() -> Child) {
	return Show.when(source, render);
}

inline function otherwise(source:ReadOnlySignal<Bool>, render:() -> Child) {
	return Show.unless(source, render);
}

inline function each<T:{}>(source:ReadOnlySignal<Array<T>>, render:(value:T) -> Child) {
	return For.each(source, render);
}
