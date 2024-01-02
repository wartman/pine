package pine.html;

import pine.html.HtmlAttributes;

// We're not using tink directly as I don't need everything it provides.
// From: https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Tags.hx
typedef HtmlTags = {
  final normal:{
    final html:GlobalAttr;
    final body:GlobalAttr;
    final iframe:IFrameAttr;
    final object:ObjectAttr;
    final head:GlobalAttr;
    final title:GlobalAttr;
    final div:GlobalAttr;
    final code:GlobalAttr;
    final aside:GlobalAttr;
    final article:GlobalAttr;
    final blockquote:GlobalAttr;
    final section:GlobalAttr;
    final header:GlobalAttr;
    final footer:GlobalAttr;
    final main:GlobalAttr;
    final nav:GlobalAttr;
    final table:GlobalAttr;
    final thead:GlobalAttr;
    final tbody:GlobalAttr;
    final tfoot:GlobalAttr;
    final tr:GlobalAttr;
    final td:TableCellAttr;
    final th:TableCellAttr;
    final h1:GlobalAttr;
    final h2:GlobalAttr;
    final h3:GlobalAttr;
    final h4:GlobalAttr;
    final h5:GlobalAttr;
    final h6:GlobalAttr;
    final strong:GlobalAttr;
    final em:GlobalAttr;
    final span:GlobalAttr;
    final a:AnchorAttr;
    final p:GlobalAttr;
    final ins:GlobalAttr;
    final del:GlobalAttr;
    final i:GlobalAttr;
    final b:GlobalAttr;
    final small:GlobalAttr;
    final menu:GlobalAttr;
    final ul:GlobalAttr;
    final ol:GlobalAttr;
    final li:GlobalAttr;
    final label:LabelAttr;
    final button:ButtonAttr;
    final pre:GlobalAttr;
    final picture:GlobalAttr;
    final canvas:CanvasAttr;
    final audio:AudioAttr;
    final video:VideoAttr;
    final form:FormAttr;
    final fieldset:FieldSetAttr;
    final legend:GlobalAttr;
    final select:SelectAttr;
    final option:OptionAttr;
    final dl:GlobalAttr;
    final dt:GlobalAttr;
    final dd:GlobalAttr;
    final details:DetailsAttr;
    final summary:GlobalAttr;
    final figure:GlobalAttr;
    final figcaption:GlobalAttr;
  }
  final opaque:{
    final textarea:TextAreaAttr;
    final script:ScriptAttr;
    final style:StyleAttr;
  }
  final void:{
    final br:GlobalAttr;
    final embed:EmbedAttr;
    final hr:GlobalAttr;
    final img:ImageAttr;
    final input:InputAttr;
    final link:LinkAttr;
    final meta:MetaAttr;
    final param:ParamAttr;
    final source:SourceAttr;
    final track:TrackAttr;
    final wbr:GlobalAttr;
  }
};
