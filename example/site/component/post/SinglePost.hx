package site.component.post;

import site.data.Post;
import pine.bridge.ServerComponent;
import site.component.core.Panel;

class SinglePost extends ServerComponent {
  @:attribute final id:Int;

  function render():Task<Child> {
    return Post.from(this)
      .fetch(id)
      .next(post -> view(<Panel>
        <h2>{post.title}</h2>
        <p>{post.content}</p>
      </Panel>));
  }
}
