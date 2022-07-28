package pine;

inline function track(handler) {
  return new Observer(handler);
}

inline function untrack(handler) {
  return new Observer(handler, true);
}

inline function compute(compute) {
  return new Computation(compute);
}

inline function createState<T>(value:T):State<T> {
  return new State(value);
}
