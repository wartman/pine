package pine.bridge;

class AssetLinks extends Component {
  function render() {
    var assets = get(AssetContext);
    // // @todo: We only want the assets for the current route, so
    // // something like this:
    // var links = assets.current()
    //   .map(assets -> assets.getLinks())
    //   .flatten();

    // @todo
    return null;
  }
}
