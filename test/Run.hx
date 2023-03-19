import medic.DefaultReporter;
import medic.Runner;

// @todo: Replace Medic with Kit.Spec

function main() {
  var runner = new Runner(new DefaultReporter({
    trackProgress: true,
    verbose: true
  }));

  runner.add(new unit.TestFragment());

  runner.add(new unit.state.TestObserver());
  runner.add(new unit.state.TestComputation());
  runner.add(new unit.state.TestTrackedObject());

  runner.add(new unit.core.TestObjectTools());
  runner.add(new unit.core.TestHasAutoConstructor());

  runner.run();
}
