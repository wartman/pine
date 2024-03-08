package site.page;

import site.layout.MainLayout;
import pine.router.Page;

class HomePage extends Page<'/'> {
  function render() {
    return MainLayout.build({
      title: 'Home',
      children: []
    });
  }
}
