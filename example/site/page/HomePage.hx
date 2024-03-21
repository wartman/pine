package site.page;

import pine.bridge.ServerComponent;
import site.component.core.*;
import site.layout.MainLayout;

class HomePage extends ServerComponent {
  function render():Task<Child> {
    return view(<MainLayout title="Home">
      <Section constrain>
        <p>"This is an example of how Pine Bridge can work!"</p>
        <p>"Click on any of the menu items to check out further examples."</p>
      </Section>
    </MainLayout>);
  }
}
