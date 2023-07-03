package spec;

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
      it('should update when internal signals change');
      it('should allow internal signals to dispatch updates, as long as it doesn\'t depend on them', spec -> {
        var test = createScope(() -> {
          var signal = new Signal('one');
          var expected = 'one';
          
          Observer.track(() -> {
            signal().should().be(expected);
          });
          Observer.track(() -> {
            expected = 'two';
            signal.set(expected);
          });
        });
        spec.expect(2);
        test();
      });
    });

    describe('pine.signal.Computation', () -> {
      it('should update when its dependencies do', createScope(() -> {
        var called = 0;
        var one = new Signal('one');
        var two = new Signal('two');
        var computed = new Computation(() -> {
          called++;
          one() + ' ' + two();
        });
        
        computed.peek().should().be('one two');
        called.should().be(1);
        
        two.set('three');

        computed.peek().should().be('one three');
        called.should().be(2);

        two.set('three');

        computed.peek().should().be('one three');
        called.should().be(2);
      }));
      it('should update observers', spec -> {
        var test = createScope(() -> {
          var one = new Signal('one');
          var two = new Signal('two');
          var computed = new Computation(() -> one() + ' ' + two());
          var expected = 'one two';

          Observer.track(() -> {
            computed().should().be(expected);
          });

          expected = 'one three';
          two.set('three');

          expected = 'two three';
          one.set('two');
        });
        spec.expect(3);
        test();
      });
      it('should update observers when updated from another observer', spec -> {
        var test = createScope(() -> {
          var one = new Signal('one');
          var two = new Signal('two');
          var computed = new Computation(() -> one() + ' ' + two());
          var expected = 'one two';

          Observer.track(() -> {
            computed().should().be(expected);
          });
          
          Observer.track(() -> {
            expected = '${one()} three';
            two.set('three');
          });
        });
        spec.expect(2);
        test();
      });
    });
  }
}
