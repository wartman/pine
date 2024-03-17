package site.island;

import pine.bridge.Island;
import site.component.core.*;

class CounterIsland extends Island {
  @:signal public final count:Int;
  @:computed public final display:String = Std.string(count());

  public function decrement() {
    if (count() > 0) count.update(i -> i - 1);
  }

  public function increment() {
    count.update(i -> i + 1);
  }

  function render():Child {
    return view(<div>
      <div>'Current count: ' display</div>
      <div class={Breeze.compose(
        Flex.display(),
        Flex.gap(3)
      )}>
        <Button action=decrement>
          <svg class={Breeze.compose(
            Sizing.height(8),
            Sizing.width(8),
            Layout.display('block'),
            Svg.fill('currentColor')
          )} viewBox="0 0 40 40">
            <path d="m24.875 11.199-11.732 8.8008 11.732 8.8008 1.2012-1.6016-9.5996-7.1992 9.5996-7.1992z"/>
          </svg>
        </Button>
        <Button action=increment>
          <svg class={Breeze.compose(
            Sizing.height(8),
            Sizing.width(8),
            Layout.display('block'),
            Svg.fill('currentColor')
          )} viewBox="0 0 40 40">
            <path d="m15.125 11.199-1.2012 1.6016 9.5996 7.1992-9.5996 7.1992 1.2012 1.6016 11.732-8.8008z"/>
          </svg>
        </Button>
      </div>
    </div>);
  }
}
