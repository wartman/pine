import medic.Runner;

function main() {
  var runner = new Runner();

  runner.add(new unit.TestFragment());

  runner.add(new unit.state.TestObserver());
  runner.add(new unit.state.TestComputation());
  runner.add(new unit.state.TestTrackedObject());

  runner.add(new unit.core.TestObjectTools());
  runner.add(new unit.core.TestHasLazyProps());
  runner.add(new unit.core.TestHasAutoConstructor());

  runner.run();
}
