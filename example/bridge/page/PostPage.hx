package bridge.page;

import bridge.core.DataContext;
import pine.*;
import pine.bridge.Page;
import pine.html.Html;
import pine.signal.*;
import bridge.layout.MainLayout;

using haxe.io.Path;
using pine.signal.Tools;

class PostPage extends Page<'/post/{id:String}'> {
  public function render():Child {
    var data = get(DataContext);
    var resource = Resource.suspends(this).fetch(() -> data.getPost(params.id));
    return Html.template(<MainLayout>
      {resource.scope(res -> switch res {
        case Error(e):
          <>{e.message}</>;
        case Loading:
          <>'Loading...'</>;
        case Ok(post):
          <h1>{post.title}</h1>;
      })}
    </MainLayout>);
  }
}