import medic.*;
import unit.*;
import integration.*;

function main() {
  var tests = new Runner(new DefaultReporter({
    title: 'Pine Tests',
    verbose: true,
    trackProgress: true
  }));

  var foo = new pine.TrackedObject<{
    foo:String,
    items:Array<String>, 
    stuff:Map<String, String>
  }>({
    foo: 'foo',
    items: [ 'yay' ],
    stuff: [ 'a' => 'zip' ]
  });

  var obs = new pine.Observer(() -> {
    trace(foo.foo);
    trace(foo.items[0]);
    trace(foo.stuff['a']);
  });

  foo.foo = 'bar';
  foo.foo = 'bin';
  foo.items[0] = 'nay';
  foo.stuff['a'] = 'bax';
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
