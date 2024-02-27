package bridge;

import bridge.page.*;
import pine.bridge.*;

function bridgeRoot() {
  trace(HomePage);
  Bridge
    .build({
      client: {
        hxml: 'dependencies',
      },
      children: () -> Router.build({
        routes: [
          new HomePage({})
        ],
        fallback: _ -> 'Not found'
      })
    })
    .generate()
    .next(assets -> assets.process())
    .handle(result -> switch result {
      case Ok(_): trace('ok');
      case Error(error): trace(error.message);
    });
}
