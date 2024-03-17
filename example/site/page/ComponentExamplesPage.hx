package site.page;

import site.layout.MainLayout;
import site.island.ExamplesIsland;
import site.component.core.*;
import pine.router.Page;

class ComponentExamplesPage extends Page<'/examples'> {
  function render():Child {
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
