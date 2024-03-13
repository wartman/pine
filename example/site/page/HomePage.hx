package site.page;

import site.layout.MainLayout;
import pine.router.Page;

class HomePage extends Page<'/'> {
  function render() {
    return view(<MainLayout title="Home">
      <p>"This is an example of how Pine Bridge can work!"</p>
      <p>"Click on any of the menu items to check out further examples."</p>
    </MainLayout>);
  }
}
