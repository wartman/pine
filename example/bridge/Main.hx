package bridge;

import bridge.core.*;
import bridge.page.*;
import kit.file.*;
import kit.file.adaptor.SysAdaptor;
import pine.*;
import pine.bridge.*;
import pine.router.*;

function bridgeRoot() {
  var fs = new FileSystem(new SysAdaptor(Sys.getCwd()));

  Bridge
    .build({
      client: {
        hxml: 'dependencies',
        // @todo: Come up with a better way to handle Breeze.
        flags: [ '-D breeze.output=none' ]
      },
      children: () -> Provider
        .provide(new DataContext(fs.directory('example/bridge/data')))
        .children(
          Router.build({
            routes: [
              HomePage.route(),
              PostPage.route(),
              TodoExample.route()
            ],
            fallback: _ -> 'Not found'
          })
        )
    })
    .generate()
    .next(assets -> assets.process())
    .handle(result -> switch result {
      case Ok(_): trace('ok');
      case Error(error): trace(error.message);
    });
}
