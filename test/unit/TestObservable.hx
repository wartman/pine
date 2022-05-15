package unit;

import pine.Observable;
import pine.ObservableHost;

using Medic;

// @todo: More extensive tests on auto dispose.
class TestObservable implements TestCase {
  public function new() {}

  @:test
  public function observableIsAnObservableHost() {
    var obs = new Observable('foo');
    obs.observe().equals(obs);

    function expectesObservableHost(obs:ObservableHost<String>) {
      Assert.pass();
    }

    // note: This will fail to compile if Observable is not an
    // ObservableHost.
    expectesObservableHost(obs);
  }

  @:test
  public function bindSimple() {
    var obs = new Observable('foo');
    var expected = 'foo';

    obs.bind(value -> value.equals(expected));
    expected = 'bar';
    obs.update('bar');
  }

  @:test
  public function testNotify() {
    var obs = new Observable('foo');
    var out = '';

    obs.bind(value -> out += value + '1');
    var link = obs.bind(value -> out += value + '2');
    obs.bind(value -> out += value + '3');

    out = '';

    obs.update('foo');
    out.equals(''); // No update if values are the same.

    obs.notify(); // force notification.
    out.equals('foo3foo2foo1');

    out = '';
    obs.update('bar');
    out.equals('bar3bar2bar1');

    out = '';
    link.dispose();
    obs.notify();
    out.equals('bar3bar1'); // Second observer should be disposed.
  }

  @:test('Observable.handle allows us to stop observing internally')
  public function observerHandleable() {
    var obs = new Observable(0);
    var called = 0;
    var times = 0;
    obs.handle(value -> {
      ++called;
      value.equals(times);
      return if (value == 2) Handled else Pending;
    }, {defer: true});

    times++;
    obs.update(1);
    times++;
    obs.update(2);
    obs.update(3);

    called.equals(2);
  }

  @:test
  function basicMappingWorks() {
    var obs = new Observable('foo');
    var expected = 'foo:bar';
    var mapped = obs.map(value -> value + ':bar');
    var called = 0;

    // Should have one mapped observer:
    obs.length.equals(1);

    mapped.bind(value -> {
      called++;
      value.equals(expected);
    }, {defer: true});

    expected = 'bar:bar';
    obs.update('bar'); // Should notify mapped observer
    called.equals(1);

    mapped.dispose();
    obs.update('some value'); // Should not notify anything
    called.equals(1);

    // Removing a mapped observable should remove its linked observer
    // as well:
    obs.length.equals(0);
  }

  @:test
  function basicAutoDispose() {
    var obs = new Observable('foo', {autoDispose: true});
    var binding = obs.bind(value -> null);
    binding.dispose();
    @:privateAccess obs.isDisposed.isTrue();
  }

  @:test
  function mapAutoDisposesByDefault() {
    var obs = new Observable(1);
    var binding = obs.map(value -> value).bind(value -> null);
    obs.length.equals(1);
    binding.dispose();
    obs.length.equals(0);
  }

  @:test
  function settingAutoDisposeToFalseOnAMappingKeepsIt() {
    var obs = new Observable(1);
    var binding = obs.map(value -> value, {autoDispose: false}).bind(value -> null);
    obs.length.equals(1);
    binding.dispose();
    obs.length.equals(1);
  }
}
