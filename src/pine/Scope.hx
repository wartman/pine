package pine;

import pine.signal.Computation;

class Scope extends AutoComponent {
  final childWithContext:(context:Component)->Component;
  final options:{ untrack:Bool };
  
  public function new(child, ?options) {
    this.childWithContext = child;
    this.options = options ?? { untrack: false };
  }

  function build():Component {
    if (options.untrack) return childWithContext(this);
    return new Fragment(new Computation(() -> [ childWithContext(this) ]));
  }
}

// // @todo: The following is broken, but the idea is to
// // create a version of Scope that actually disposes
// // unused Signals when it re-renders.

// import pine.internal.Slot;
// import pine.signal.Graph.withOwner;
// import pine.Disposable;
// import pine.debug.Debug;
// import pine.signal.*;

// class Scope extends Component {
//   final build:(context:Component)->Component;
//   final options:{ untrack:Bool };
//   var child:Null<Component> = null;

//   public function new(build, ?options) {
//     this.build = build;
//     this.options = options ?? { untrack: false };
//   }

//   public function getObject():Dynamic {
//     var object = child?.getObject();

//     if (object == null) {
//       error('Could not resolve an object');
//     }

//     return object;
//   }

//   public function visitChildren(visitor:(child:Component) -> Bool) {
//     if (child != null) visitor(child);
//   }

//   public function initialize() {
//     assert(componentLifecycleStatus != Disposed);
//     assert(componentBuildStatus != Building);
//     assert(child == null);

//     var owner = new DisposableCollection();
//     addDisposable(owner);

//     Observer.track(() -> {
//       assert(componentBuildStatus != Building);
//       assert(componentLifecycleStatus != Disposed);

//       if (child != null) {
//         child.dispose();
//         child = null;
//       }
      
//       owner.dispose();
//       componentBuildStatus = Building;

//       withOwner(owner, () -> {
//         child = build(this);
//         switch componentLifecycleStatus {
//           case Hydrating(cursor):
//             child.hydrate(this, cursor, slot);
//           default:
//             child.mount(this, slot);
//         }
//       });

//       componentBuildStatus = Built;
//     });
//   }

//   override function updateSlot(?newSlot:Slot) {
//     super.updateSlot(newSlot);
//     child?.updateSlot(newSlot);
//   }

//   override function dispose() {
//     super.dispose();
//     if (child != null) {
//       child.dispose();
//       child = null;
//     }
//   }
// }
