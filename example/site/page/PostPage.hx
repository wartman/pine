package site.page;

import pine.router.Page;
import site.layout.MainLayout;
import site.component.post.*;
import site.component.core.*;

class PostPage extends Page<'/post/{id:Int}'> {
  function render() {
    return view(<MainLayout title={'Post | ${params.id}'}>
      <Section constrain>
        <SinglePost id={params.id} />
      </Section>
    </MainLayout>);
  }
}
