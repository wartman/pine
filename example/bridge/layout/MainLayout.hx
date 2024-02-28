package bridge.layout;

import pine.*;
import pine.html.Html;
import bridge.page.*;

class MainLayout extends Component {
  @:attribute final title:String = null;
  @:children @:attribute final children:Children;

  function render():Child {
    return Html.template(<html>
      <head>
        <title>title</title>
        <link rel="stylesheet" href="/styles.css" />
      </head>

      <body>
        <header>
          <h3>"This is a test"</h3>
          <nav>
            <ul>
              <li>{PostPage.link({ id: '001' }).children('First Post')}</li>
              <li>{PostPage.link({ id: '002' }).children(<b>'Second post'</b>)}</li>
            </ul>
          </nav>
        </header>
        {children}
        <script src="/app.js" />
      </body>
    </html>);
  }
}
