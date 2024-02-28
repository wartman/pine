package bridge;

import kit.file.adaptor.SysAdaptor;
import bridge.core.*;
import kit.file.*;
import pine.*;
import bridge.page.*;
import pine.bridge.*;

function bridgeRoot() {
  var fs = new FileSystem(new SysAdaptor(Sys.getCwd()));

  Bridge
    .build({
      client: {
        hxml: 'dependencies',
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
