package site.island;

import pine.bridge.Island;
import site.component.example.*;

class ExamplesIsland extends Island {
  function render():Child {
    return Html.div()
      .children(
        CarouselExample.build({}),
        CollapseExample.build({}),
        AnimationExample.build({})
      );
  }
}
