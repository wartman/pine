import medic.*;
import unit.*;
import integration.*;

function main() {
  var tests = new Runner(new DefaultReporter({
    title: 'Pine Tests',
    verbose: true,
    trackProgress: true
  }));

  addUnitTests(tests);
  addIntegrationTests(tests);

  tests.run();
}

function addUnitTests(tests:Runner) {
  tests.add(new TestFragment());

  tests.add(new TestService());
  
  tests.add(new TestObserver());
  tests.add(new TestComputation());

  tests.add(new TestTrackedObject());
}

function addIntegrationTests(tests:Runner) {
  // tests.add(new TestKeySorting());
}
