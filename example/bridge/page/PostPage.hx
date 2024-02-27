package bridge.page;

import pine.*;
import pine.html.Html;
import pine.bridge.Page;

class PostPage implements Page<'/post/{id:String}'> {
  public function render():Child {
    return Html.template(<>
      <h1>{params().id}</h1>  
    </>);
  }
}
