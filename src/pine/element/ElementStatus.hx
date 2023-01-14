package pine.element;

enum ElementStatus {
  Pending;
  Valid;
  Invalid;
  Building;
  Disposing;
  Disposed;
  Failed<T>(error:T);
}
