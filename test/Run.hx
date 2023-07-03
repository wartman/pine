import kit.spec.reporter.ConsoleReporter;

using kit.Spec;

function main() {
  var reporter = new ConsoleReporter({
    title: 'Pine Tests',
    verbose: true,
    trackProgress: true
  });
  var runner = new Runner();

  runner.addReporter(reporter);

  runner.add(spec.Signals);
  runner.add(spec.Resources);

  runner.run();
}
