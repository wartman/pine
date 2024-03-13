package site.page;

import pine.router.Page;
import site.layout.MainLayout;
import site.component.post.*;

class PostPage extends Page<'/post/{id:Int}'> {
  function render() {
    return view(<MainLayout title={'Post | ${params.id}'}>
      <SinglePost id={params.id} />
    </MainLayout>);
  }
}
