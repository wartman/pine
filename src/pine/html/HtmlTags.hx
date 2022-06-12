package pine.html;

import pine.html.HtmlAttributes;

// We're not using tink directly as I don't need everything it provides.
// From: https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Tags.hx
typedef HtmlTags = {
  var normal:{
    var html:GlobalAttr;
    var body:GlobalAttr;
    var iframe:IFrameAttr;
    var object:ObjectAttr;
    var head:GlobalAttr;
    var title:GlobalAttr;
    var div:GlobalAttr;
    var code:GlobalAttr;
    var aside:GlobalAttr;
    var article:GlobalAttr;
    var blockquote:GlobalAttr;
    var section:GlobalAttr;
    var header:GlobalAttr;
    var footer:GlobalAttr;
    var main:GlobalAttr;
    var nav:GlobalAttr;
    var table:GlobalAttr;
    var thead:GlobalAttr;
    var tbody:GlobalAttr;
    var tfoot:GlobalAttr;
    var tr:GlobalAttr;
    var td:TableCellAttr;
    var th:TableCellAttr;
    var h1:GlobalAttr;
    var h2:GlobalAttr;
    var h3:GlobalAttr;
    var h4:GlobalAttr;
    var h5:GlobalAttr;
    var h6:GlobalAttr;
    var strong:GlobalAttr;
    var em:GlobalAttr;
    var span:GlobalAttr;
    var a:AnchorAttr;
    var p:GlobalAttr;
    var ins:GlobalAttr;
    var del:GlobalAttr;
    var i:GlobalAttr;
    var b:GlobalAttr;
    var small:GlobalAttr;
    var menu:GlobalAttr;
    var ul:GlobalAttr;
    var ol:GlobalAttr;
    var li:GlobalAttr;
    var label:LabelAttr;
    var button:ButtonAttr;
    var pre:GlobalAttr;
    var picture:GlobalAttr;
    var canvas:CanvasAttr;
    var audio:AudioAttr;
    var video:VideoAttr;
    var form:FormAttr;
    var fieldset:FieldSetAttr;
    var legend:GlobalAttr;
    var select:SelectAttr;
    var option:OptionAttr;
    var dl:GlobalAttr;
    var dt:GlobalAttr;
    var dd:GlobalAttr;
    var details:DetailsAttr;
    var summary:GlobalAttr;
    var figure:GlobalAttr;
    var figcaption:GlobalAttr;
  }
  var opaque:{
    var textarea:TextAreaAttr;
    var script:ScriptAttr;
    var style:StyleAttr;
  }
  var void:{
    var br:GlobalAttr;
    var embed:EmbedAttr;
    var hr:GlobalAttr;
    var img:ImageAttr;
    var input:InputAttr;
    var link:LinkAttr;
    var meta:MetaAttr;
    var param:ParamAttr;
    var source:SourceAttr;
    var track:TrackAttr;
    var wbr:GlobalAttr;
  }
};
