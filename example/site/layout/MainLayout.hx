package site.layout;

import site.component.SiteHeader;

class MainLayout extends Component {
  @:attribute final title:String;
  @:children @:attribute final children:Children; 

  function render():Child {
    return view(
      <html>
        <head>
          <title>title</title>
          <link rel="stylesheet" href="/styles.css" />
        </head>

        <body>
          <SiteHeader />
          <main>
            children
          </main>
          <script src="/app.js" />
        </body>
      </html>
    );
  }
}
