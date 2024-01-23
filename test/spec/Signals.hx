package spec;

// @todo: Need to implement tests.
class Signals extends Suite {
  function execute() {
    describe('pine.signal.Signal', () -> {
      it('should trigger Observers when changed');
      it('should be observable by multiple Observers');
    });

    describe('pine.signal.Action', () -> {
      it('should batch Signal updates and only run observers once');
    });

    describe('pine.signal.Observer', () -> {
      it('should allow internal signals to dispatch updates, as long as it doesn\'t depend on them');
    });

    describe('pine.signal.Computation', () -> {
      it('should update when its dependencies do');
      it('should update observers');
      it('should update observers when updated from another observer');
    });
  }
}
