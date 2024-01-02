package pine;

import pine.signal.Signal;
import pine.view.TrackedProxyView;

class Show implements Builder {
  public static inline function when(condition, successBranch) {
    return new Show(condition, successBranch);
  }

  public static inline function unless(condition:ReadOnlySignal<Bool>, successBranch) {
    return new Show(condition.map(value -> !value), successBranch);
  }

  final condition:ReadOnlySignal<Bool>;
  final successBranch:(context:Context)->Child;
  var failureBranch:Null<(context:Context)->Child> = null;

  public function new(condition, successBranch) {
    this.condition = condition;
    this.successBranch = successBranch;
  }

  public function otherwise(failureBranch) {
    this.failureBranch = failureBranch;
    return this;
  }

  public function createView(parent:View, slot:Null<Slot>):View {
    return new TrackedProxyView(parent, parent.adaptor, slot, context -> {
      if (condition()) return successBranch(context);
      return failureBranch != null ? failureBranch(context) : Placeholder.build();
    });
  }
}
