package pine.router;

// import kit.http.Request;
import pine.html.Html;

abstract Link(LinkBuilder) {
  public inline static function to(to:String) {
    return new Link(to);
  }

  public inline function new(to:String) {
    this = new LinkBuilder(to);
  }

  public inline function attr(name, value) {
    if (name == 'href') throw 'Invalid attribute: href';
    this.builder.attr(name, value);
    return abstract;
  }

  public inline function on(name, value) {
    this.builder.on(name, value);
    return abstract;
  }

  public inline function children(...views) {
    this.builder.children(...views);
    return abstract;
  }

  @:to public inline function toChild():Child {
    return toView();
  }

  @:to public inline function toChildren():Children {
    return toView();
  }

  @:to public inline function toView() {
    return LinkComponent.build({
      to: this.to,
      builder: this.builder
    });
  }
}

class LinkComponent extends Component {
  @:attribute final to:String;
  @:attribute final builder:HtmlTagBuilder;

  function render() {
    // var router = get(Router);
    var visitor = get(RouteVisitor);

    visitor?.enqueue(to);

    // if (router != null) {
    //   builder.on(Click, e -> {
    //     e.preventDefault();
    //     router.go(new Request(Get, to));
    //   });
    // }

    return builder.attr('href', to).toView();
  }
}

@:allow(pine.router.Link)
class LinkBuilder {
  final to:String;
  final builder:HtmlTagBuilder = new HtmlTagBuilder('a');

  public function new(to) {
    this.to = to;
  }
}
