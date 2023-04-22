package pine;

import pine.signal.Computation;

class Scope extends AutoComponent {
  final childWithContext:(context:Component)->Component;
  
  public function new(child) {
    this.childWithContext = child;
  }

  function build():Component {
    return new Fragment(new Computation(() -> [ childWithContext(this) ]));
  }
}

// // The following may be overkill:

// import pine.debug.Debug;
// import pine.signal.Observer;

// class Scope extends Component {
//   final build:(context:Component)->Component;
//   var child:Null<Component>;
  
//   public function new(build) {
//     this.build = build;
//   }

//   public function getObject():Dynamic {
//     assert(child != null, 'Could not resolve object');
//     return child?.getObject();
//   }

//   public function visitChildren(visitor:(child:Component) -> Bool) {
//     if (child != null) visitor(child);
//   }

//   override function updateSlot(?newSlot:Slot) {
//     super.updateSlot(newSlot);
//     child?.updateSlot(newSlot);
//   }

//   public function initialize() {
//     var previousChild = child;
//     Observer.track(() -> {
//       assert(componentLifecycleStatus != Disposed);
//       assert(componentBuildStatus != Building);

//       if (componentLifecycleStatus == Disposing) return;

//       componentBuildStatus = Building;
//       child = build(this);
//       if (child == null) child = new Placeholder();
//       if (child == previousChild) {
//         componentBuildStatus = Built;
//         return;
//       }
  
//       if (previousChild != null) previousChild.dispose();
//       previousChild = child;

//       switch componentLifecycleStatus {
//         case Hydrating(cursor):
//           child.hydrate(this, cursor, slot);
//         default:
//           child.mount(this, slot);
//       }

//       componentBuildStatus = Built;
//     });
//   }
// }
