// @todo: @:html(...) and @:jsOnly currently have no effect.
package pine.html;

// Taken from: https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Aria.hx
typedef AriaAttributes = {
  @:html('aria-label') @:optional final ariaLabel:String;
  @:html('aria-current') @:optional final ariaCurrent:String;
  @:html('aria-labeledby') @:optional final ariaLabelledby:String;
  @:html('aria-describedby') @:optional final ariaDescribedby:String;
  @:html('aria-autocomplete') @:optional final ariaAutocomplete:String;
  @:html('aria-dropeffect') @:optional final ariaDropEffect:String;
  @:html('aria-hidden') @:optional final ariaHidden:Bool;
  @:html('aria-disabled') @:optional final ariaDisabled:Bool;
  @:html('aria-checked') @:optional final ariaChecked:Bool;
  @:html('aria-haspopup') @:optional final ariaHasPopup:Bool;
  @:html('aria-grabbed') @:optional final ariaGrabbed:Bool;
  @:html('aria-valuenow') @:optional final ariaValuenow:Float;
  @:html('aria-valuemin') @:optional final ariaValuemin:Float;
  @:html('aria-valuemax') @:optional final ariaValuemax:Float;
  @:html('aria-valuetext') @:optional final ariaValuetext:String;
  @:html('aria-modal') @:optional final ariaModal:String;
}

// From https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Attributes.hx
typedef GlobalAttr = AriaAttributes & {
  @:html('class') @:optional var className:String;
  @:optional var id:String;
  @:optional var title:String;
  @:optional var lang:String;
  @:optional var dir:String;
  @:optional var contentEditable:Bool;
  @:optional var inputmode:Bool;

  @:optional var hidden:Bool;
  @:optional var tabIndex:Int;
  @:optional var accessKey:String;
  @:optional var draggable:Bool;
  @:optional var spellcheck:Bool;
  @:optional var style:String;
  @:optional var role:String;
}

typedef DetailsAttr = GlobalAttr & {
  @:optional var open:Bool;
}

typedef FieldSetAttr = GlobalAttr & {
  @:optional var disabled:Bool;
  @:optional var name:String;
}

typedef ObjectAttr = GlobalAttr & {
  @:optional var type:String;
  @:optional var data:String;
  @:optional var width:Int;
  @:optional var height:Int;
}

typedef ParamAttr = GlobalAttr & {
  var name:String;
  var value:String;
}

typedef TableCellAttr = GlobalAttr & {
  @:optional var abbr:String;
  @:optional var colSpan:Int;
  @:optional var headers:String;
  @:optional var rowSpan:Int;
  @:optional var scope:String;
  @:optional var sorted:String;
}

enum abstract InputType(String) to String {
  var Text = 'text';
  var Button = 'button';
  var Checkbox = 'checkbox';
  var Color = 'color';
  var Date = 'date';
  var DatetimeLocal = 'datetime-local';
  var Email = 'email';
  var File = 'file';
  var Hidden = 'hidden';
  var Image = 'image';
  var Month = 'month';
  var Number = 'number';
  var Password = 'password';
  var Radio = 'radio';
  var Range = 'range';
  var Reset = 'reset';
  var Search = 'search';
  var Tel = 'tel';
  var Submit = 'submit';
  var Time = 'time';
  var Url = 'url';
  var Week = 'week';
}

typedef InputAttr = GlobalAttr & {
  @:optional var checked:Bool;
  @:optional var disabled:Bool;
  @:optional var required:Bool;
  @:optional var autofocus:Bool;
  @:optional var autocomplete:String;
  @:optional var value:String;
  @:optional var readOnly:Bool;
  @:html('value') @:optional var defaultValue:String;
  @:optional var type:InputType;
  @:optional var name:String;
  @:optional var placeholder:String;
  @:optional var max:String;
  @:optional var min:String;
  @:optional var step:String;
  @:optional var maxLength:Int;
  @:optional var pattern:String;
  @:optional var accept:String;
  @:optional var multiple:Bool;
}

typedef ButtonAttr = GlobalAttr & {
  @:optional var disabled:Bool;
  @:optional var autofocus:Bool;
  @:optional var type:String;
  @:optional var name:String;
}

typedef TextAreaAttr = GlobalAttr & {
  @:optional var autofocus:Bool;
  @:optional var cols:Int;
  @:optional var dirname:String;
  @:optional var disabled:Bool;
  @:optional var form:String;
  @:optional var maxlength:Int;
  @:optional var name:String;
  @:optional var placeholder:String;
  @:optional var readOnly:Bool;
  @:optional var required:Bool;
  @:optional var rows:Int;
  @:optional var value:String;
  @:optional var defaultValue:String;
  @:optional var wrap:String;
}

typedef IFrameAttr = GlobalAttr & {
  @:optional var sandbox:String;
  @:optional var width:Int;
  @:optional var height:Int;
  @:optional var src:String;
  @:optional var srcdoc:String;
  @:optional var allowFullscreen:Bool;
  @:deprecated @:optional var scrolling:IframeScrolling;
}

enum abstract IframeScrolling(String) {
  var Yes = "yes";
  var No = "no";
  var Auto = "auto";
}

typedef ImageAttr = GlobalAttr & {
  @:optional var src:String;
  @:optional var width:Int;
  @:optional var height:Int;
  @:optional var alt:String;
  @:optional var srcset:String;
  @:optional var sizes:String;
}

private typedef MediaAttr = GlobalAttr & {
  @:optional var src:String;
  @:optional var autoplay:Bool;
  @:optional var controls:Bool;
  @:optional var loop:Bool;
  @:optional var muted:Bool;
  @:optional var preload:String;
  @:optional var volume:Float;
}

typedef AudioAttr = MediaAttr & {};

typedef VideoAttr = MediaAttr & {
  @:optional var height:Int;
  @:optional var poster:String;
  @:optional var width:Int;
  @:optional var playsInline:Bool;
}

typedef SourceAttr = GlobalAttr & {
  @:optional var src:String;
  @:optional var srcset:String;
  @:optional var media:String;
  @:optional var sizes:String;
  @:optional var type:String;
}

typedef LabelAttr = GlobalAttr & {
  @:html('for') @:optional var htmlFor:String;
}

typedef SelectAttr = GlobalAttr & {
  @:optional var autofocus:Bool;
  @:optional var disabled:Bool;
  @:optional var multiple:Bool;
  @:optional var name:String;
  @:optional var required:Bool;
  @:optional var size:Int;
}

typedef FormAttr = GlobalAttr & {
  @:optional var method:String;
  @:optional var action:String;
}

typedef AnchorAttr = GlobalAttr & {
  @:optional var href:String;
  @:optional var target:String;
  @:optional var type:String;
  @:optional var rel:AnchorRel;
}

typedef OptionAttr = GlobalAttr & {
  @:optional var disabled:Bool;
  @:optional var label:String;
  @:jsOnly @:optional var defaultSelected:Bool;
  @:optional var selected:Bool;
  @:optional var value:String;
  @:optional var text:String;
  @:optional var index:Int;
}

typedef MetaAttr = GlobalAttr & {
  @:optional var content:String;
  @:optional var name:String;
  @:optional var charset:String;
  @:optional var httpEquiv:MetaHttpEquiv;
}

enum abstract MetaHttpEquiv(String) to String from String {
  var ContentType = "content-type";
  var DefaultStyle = "default-style";
  var Refresh = "refresh";
}

typedef LinkAttr = GlobalAttr & {
  var rel:LinkRel;
  @:optional var crossorigin:LinkCrossOrigin;
  @:optional var href:String;
  @:optional var hreflang:String;
  @:optional var media:String;
  @:optional var sizes:String;
  @:optional var type:String;
}

enum abstract LinkRel(String) to String from String {
  var Alternate = "alternate";
  var Author = "author";
  var DnsPrefetch = "dns-prefetch";
  var Help = "help";
  var Icon = "icon";
  var License = "license";
  var Next = "next";
  var Pingback = "pingback";
  var Preconnect = "preconnect";
  var Prefetch = "prefetch";
  var Preload = "preload";
  var Prerender = "prerender";
  var Prev = "prev";
  var Search = "search";
  var Stylesheet = "stylesheet";
}

enum abstract AnchorRel(String) to String from String {
  var Alternate = "alternate";
  var Author = "author";
  var Bookmark = "bookmark";
  var External = "external";
  var Help = "help";
  var License = "license";
  var Next = "next";
  var NoFollow = "nofollow";
  var NoReferrer = "noreferrer";
  var NoOpener = "noopener";
  var Prev = "prev";
  var Search = "search";
  var Tag = "tag";
}

enum abstract LinkCrossOrigin(String) to String from String {
  var Anonymous = "anonymous";
  var UseCredentials = "use-credentials";
}

typedef ScriptAttr = GlobalAttr & {
  @:optional var async:Bool;
  @:optional var charset:String;
  @:optional var defer:Bool;
  @:optional var src:String;
  @:optional var type:String;
}

typedef StyleAttr = GlobalAttr & {
  @:optional var type:String;
  @:optional var media:String;
  @:optional var nonce:String;
}

typedef CanvasAttr = GlobalAttr & {
  @:optional var width:String;
  @:optional var height:String;
}

typedef TrackAttr = {
  var src:String;
  @:optional var kind:TrackKind;
  @:optional var label:String;
  @:optional var srclang:String;
}

enum abstract TrackKind(String) to String from String {
  var Subtitles = 'subtitles';
  var Captions = 'captions';
  var Descriptions = 'descriptions';
  var Chapters = 'chapters';
  var Metadata = 'metadata';
}

typedef EmbedAttr = {
  var height:Int;
  var width:Int;
  var src:String;
  var typed:String;
}
