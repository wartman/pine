import medic.*;
import unit.*;
import integration.*;

function main() {
  var tests = new Runner(new DefaultReporter({
    title: 'Pine Tests',
    verbose: true,
    trackProgress: true
  }));

  var foo = new pine.track.TrackedObject<{foo:String}>({
    foo: 'foo'
  });
  var obs = new pine.track.Observer(() -> {
    trace(foo.foo);
  });

  foo.foo = 'bar';
  foo.foo = 'bin';
  obs.dispose();

  addUnitTests(tests);
  addIntegrationTests(tests);

  tests.run();
}

function addUnitTests(tests:Runner) {
  tests.add(new TestFragment());
}

function addIntegrationTests(tests:Runner) {
  // tests.add(new TestKeySorting());
}
