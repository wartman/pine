package pine.html;

import pine.html.HtmlEvents;
import pine.html.HtmlAttributes;

typedef HtmlTags = NormalHtmlTags & OpaqueHtmlTags & VoidHtmlTags;

typedef HasChildren = {
  @:children public final ?children:Children;
}

typedef NormalHtmlTags = {
  public final html:GlobalAttr & HtmlEvents & HasChildren;
  public final body:GlobalAttr & HtmlEvents & HasChildren;
  public final iframe:IFrameAttr & HtmlEvents & HasChildren;
  public final object:ObjectAttr & HtmlEvents & HasChildren;
  public final head:GlobalAttr & HtmlEvents & HasChildren;
  public final title:GlobalAttr & HtmlEvents & HasChildren;
  public final div:GlobalAttr & HtmlEvents & HasChildren;
  public final code:GlobalAttr & HtmlEvents & HasChildren;
  public final aside:GlobalAttr & HtmlEvents & HasChildren;
  public final article:GlobalAttr & HtmlEvents & HasChildren;
  public final blockquote:GlobalAttr & HtmlEvents & HasChildren;
  public final section:GlobalAttr & HtmlEvents & HasChildren;
  public final header:GlobalAttr & HtmlEvents & HasChildren;
  public final footer:GlobalAttr & HtmlEvents & HasChildren;
  public final main:GlobalAttr & HtmlEvents & HasChildren;
  public final nav:GlobalAttr & HtmlEvents & HasChildren;
  public final table:GlobalAttr & HtmlEvents & HasChildren;
  public final thead:GlobalAttr & HtmlEvents & HasChildren;
  public final tbody:GlobalAttr & HtmlEvents & HasChildren;
  public final tfoot:GlobalAttr & HtmlEvents & HasChildren;
  public final tr:GlobalAttr & HtmlEvents & HasChildren;
  public final td:TableCellAttr & HtmlEvents & HasChildren;
  public final th:TableCellAttr & HtmlEvents & HasChildren;
  public final h1:GlobalAttr & HtmlEvents & HasChildren;
  public final h2:GlobalAttr & HtmlEvents & HasChildren;
  public final h3:GlobalAttr & HtmlEvents & HasChildren;
  public final h4:GlobalAttr & HtmlEvents & HasChildren;
  public final h5:GlobalAttr & HtmlEvents & HasChildren;
  public final h6:GlobalAttr & HtmlEvents & HasChildren;
  public final strong:GlobalAttr & HtmlEvents & HasChildren;
  public final em:GlobalAttr & HtmlEvents & HasChildren;
  public final span:GlobalAttr & HtmlEvents & HasChildren;
  public final a:AnchorAttr & HtmlEvents & HasChildren;
  public final p:GlobalAttr & HtmlEvents & HasChildren;
  public final ins:GlobalAttr & HtmlEvents & HasChildren;
  public final del:GlobalAttr & HtmlEvents & HasChildren;
  public final i:GlobalAttr & HtmlEvents & HasChildren;
  public final b:GlobalAttr & HtmlEvents & HasChildren;
  public final small:GlobalAttr & HtmlEvents & HasChildren;
  public final menu:GlobalAttr & HtmlEvents & HasChildren;
  public final ul:GlobalAttr & HtmlEvents & HasChildren;
  public final ol:GlobalAttr & HtmlEvents & HasChildren;
  public final li:GlobalAttr & HtmlEvents & HasChildren;
  public final label:LabelAttr & HtmlEvents & HasChildren;
  public final button:ButtonAttr & HtmlEvents & HasChildren;
  public final pre:GlobalAttr & HtmlEvents & HasChildren;
  public final picture:GlobalAttr & HtmlEvents & HasChildren;
  public final canvas:CanvasAttr & HtmlEvents & HasChildren;
  public final audio:AudioAttr & HtmlEvents & HasChildren;
  public final video:VideoAttr & HtmlEvents & HasChildren;
  public final form:FormAttr & HtmlEvents & HasChildren;
  public final fieldset:FieldSetAttr & HtmlEvents & HasChildren;
  public final legend:GlobalAttr & HtmlEvents & HasChildren;
  public final select:SelectAttr & HtmlEvents & HasChildren;
  public final option:OptionAttr & HtmlEvents & HasChildren;
  public final dl:GlobalAttr & HtmlEvents & HasChildren;
  public final dt:GlobalAttr & HtmlEvents & HasChildren;
  public final dd:GlobalAttr & HtmlEvents & HasChildren;
  public final details:DetailsAttr & HtmlEvents & HasChildren;
  public final summary:GlobalAttr & HtmlEvents & HasChildren;
  public final figure:GlobalAttr & HtmlEvents & HasChildren;
  public final figcaption:GlobalAttr & HtmlEvents & HasChildren;
}

typedef OpaqueHtmlTags = {
  public final textarea:TextAreaAttr & HtmlEvents;
  public final script:ScriptAttr & HtmlEvents;
  public final style:StyleAttr & HtmlEvents;
}

typedef VoidHtmlTags = {
  public final br:GlobalAttr & HtmlEvents;
  public final embed:EmbedAttr & HtmlEvents;
  public final hr:GlobalAttr & HtmlEvents;
  public final img:ImageAttr & HtmlEvents;
  public final input:InputAttr & HtmlEvents;
  public final link:LinkAttr & HtmlEvents;
  public final meta:MetaAttr & HtmlEvents;
  public final param:ParamAttr & HtmlEvents;
  public final source:SourceAttr & HtmlEvents;
  public final track:TrackAttr & HtmlEvents;
  public final wbr:GlobalAttr & HtmlEvents;
} 
