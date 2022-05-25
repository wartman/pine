package notebook;

import js.Browser;
import pine.html.dom.DomBootstrap;
import notebook.ui.App;

using Nuke;

function main() {
  Css.global({
    html: {
      backgroundColor: '#1f1f1f',
      fontFamily: 'Roboto, Helvetica, Arial, sans-serif',
      fontSize: 13.px(),
      'h1, h2, h3': {
        fontSize: 15.px()
      }
    }
  });

  var boot = new DomBootstrap(Browser.document.getElementById('root'));
  boot.mount(new App({}));
}
