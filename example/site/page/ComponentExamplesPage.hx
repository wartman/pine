package site.page;

import pine.bridge.ServerComponent;
import site.layout.MainLayout;
import site.island.ExamplesIsland;
import site.component.core.*;

class ComponentExamplesPage extends ServerComponent {
  function render():Task<Child> {
    return view(
      <MainLayout title="examples">
        <Section constrain>
          <p>"This is a page with some examples of Pine Components"</p>
          <ExamplesIsland />
        </Section>
      </MainLayout>
    );
  }
}
