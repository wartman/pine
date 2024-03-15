package site.layout;

import pine.bridge.AppContext;
import site.component.SiteHeader;

class MainLayout extends Component {
  @:attribute final title:String;
  @:children @:attribute final children:Children; 

  function render():Child {
    return view(
      <html>
        <head>
          <title>title</title>
          <link rel="stylesheet" href="/assets/app.css" />
        </head>

        <body>
          <div id="portal"></div>
          <SiteHeader />
          <main>children</main>
          <script src={AppContext.from(this).getClientAppPath()} />
        </body>
      </html>
    );
  }
}
