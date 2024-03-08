package site.island;

import pine.bridge.Island;
import ex.*;

class CounterIsland extends Island {
  @:signal final count:Int = 0;

  function render():Child {
    return view(<>
      <p>{count.map(Std.string)}</p>
      <Button action={() -> count.update(i -> i + 1)}>"Increment"</Button>
    </>);
  }
}
