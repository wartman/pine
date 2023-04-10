package pine;

class Scope extends ProxyComponent {
  final buildWithContext:(context:Component)->Component;
  
  public function new(build) {
    this.buildWithContext = build;
  }

  function build():Component {
    // @todo: There's probably a better way to trigger rebuilds without
    // having to return a Fragment.
    return new Fragment(compute(() -> [ buildWithContext(this) ]));
  }
}
