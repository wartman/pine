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
  tests.add(new TestObservable());
  tests.add(new TestObservableObject());

  tests.add(new TestFragment());
}

function addIntegrationTests(tests:Runner) {
  // tests.add(new TestKeySorting());
}
