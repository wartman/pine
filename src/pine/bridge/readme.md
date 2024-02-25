# Pine Bridge

This package aims to provide low-level primitives for client/server interop. Ideally it'll be pretty generic, but really it's for HTML. Ideally in the future we'll have a way to chunk out JS, but that's pretty out of scope for the moment.

Right now, I see things working like this:

```haxe
function main() {
  Bridge
    .build({
      client: {
        outputName: 'index.js',
        libraries: [ 'kit.http' ],
        flags: [ '--debug', '-D breeze.output=skip' ]
      },
      render: () -> Html.template(<html>
        <head>
          <Head />
          <AssetLinks />
        </head>

        <body>
          <Root />
        </body>
      </html>)
    })
    .generate()
    .next(assets -> assets.process())
    .handle(result -> switch result {
      case Ok(_):
      case Error(_):
    });
}

// in another file:
class Root extends Component {
  function render() {
    return Html.template(<Router>
      <HomePage />
      <PostPage />
      <NotFoundPage />
    </Router>);
  }
}
```

...or something, the Router is not really important here. 

The main thing is that this will create a completely static site with no interactivity. For that, we need Islands, which are a special kind of component that get wrapped in a `<pine-island>` and which can be activated on the client. During the `generate` phase, every Island component will mark itself as used with the IslandContext, which is itself an Asset. During asset processing the IslandContext will:

- Create an `Islands.hx` file in the dist directory.
- Run a `haxe` command with this file as the `--main` (something like `haxe --main Islands -js dist/assets/app.js`).
- Add the output path to as an asset link.

`Islands.hx` will look something like:

```haxe
function main() {
  var root = new pine.bridge.IslandRoot([
    my.app.Island
  ]);
  root.hydrateIslands();
}
```

