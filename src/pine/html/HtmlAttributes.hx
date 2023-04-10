// @todo: @:html(...) and @:jsOnly currently have no effect.
package pine.html;

// Taken from: https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Aria.hx
typedef AriaAttributes = {
  @:html('aria-label') @:optional final ariaLabel:HtmlAttribute<String>;
  @:html('aria-current') @:optional final ariaCurrent:HtmlAttribute<String>;
  @:html('aria-labeledby') @:optional final ariaLabelledby:HtmlAttribute<String>;
  @:html('aria-describedby') @:optional final ariaDescribedby:HtmlAttribute<String>;
  @:html('aria-autocomplete') @:optional final ariaAutocomplete:HtmlAttribute<String>;
  @:html('aria-dropeffect') @:optional final ariaDropEffect:HtmlAttribute<String>;
  @:html('aria-hidden') @:optional final ariaHidden:HtmlAttribute<Bool>;
  @:html('aria-disabled') @:optional final ariaDisabled:HtmlAttribute<Bool>;
  @:html('aria-checked') @:optional final ariaChecked:HtmlAttribute<Bool>;
  @:html('aria-haspopup') @:optional final ariaHasPopup:HtmlAttribute<Bool>;
  @:html('aria-grabbed') @:optional final ariaGrabbed:HtmlAttribute<Bool>;
  @:html('aria-valuenow') @:optional final ariaValuenow:HtmlAttribute<Float>;
  @:html('aria-valuemin') @:optional final ariaValuemin:HtmlAttribute<Float>;
  @:html('aria-valuemax') @:optional final ariaValuemax:HtmlAttribute<Float>;
  @:html('aria-valuetext') @:optional final ariaValuetext:HtmlAttribute<String>;
  @:html('aria-modal') @:optional final ariaModal:HtmlAttribute<String>;
}

// From https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Attributes.hx
typedef GlobalAttr = AriaAttributes & {
  @:html('class') @:optional var className:HtmlAttribute<String>;
  @:optional var id:HtmlAttribute<String>;
  @:optional var title:HtmlAttribute<String>;
  @:optional var lang:HtmlAttribute<String>;
  @:optional var dir:HtmlAttribute<String>;
  @:optional var contentEditable:HtmlAttribute<Bool>;
  @:optional var inputmode:HtmlAttribute<Bool>;

  @:optional var hidden:HtmlAttribute<Bool>;
  @:optional var tabIndex:HtmlAttribute<Int>;
  @:optional var accessKey:HtmlAttribute<String>;
  @:optional var draggable:HtmlAttribute<Bool>;
  @:optional var spellcheck:HtmlAttribute<Bool>;
  @:optional var style:HtmlAttribute<String>;
  @:optional var role:HtmlAttribute<String>;
}

typedef DetailsAttr = GlobalAttr & {
  @:optional var open:HtmlAttribute<Bool>;
}

typedef FieldSetAttr = GlobalAttr & {
  @:optional var disabled:HtmlAttribute<Bool>;
  @:optional var name:HtmlAttribute<String>;
}

typedef ObjectAttr = GlobalAttr & {
  @:optional var type:HtmlAttribute<String>;
  @:optional var data:HtmlAttribute<String>;
  @:optional var width:HtmlAttribute<Int>;
  @:optional var height:HtmlAttribute<Int>;
}

typedef ParamAttr = GlobalAttr & {
  var name:HtmlAttribute<String>;
  var value:HtmlAttribute<String>;
}

typedef TableCellAttr = GlobalAttr & {
  @:optional var abbr:HtmlAttribute<String>;
  @:optional var colSpan:HtmlAttribute<Int>;
  @:optional var headers:HtmlAttribute<String>;
  @:optional var rowSpan:HtmlAttribute<Int>;
  @:optional var scope:HtmlAttribute<String>;
  @:optional var sorted:HtmlAttribute<String>;
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
  @:optional var checked:HtmlAttribute<Bool>;
  @:optional var disabled:HtmlAttribute<Bool>;
  @:optional var required:HtmlAttribute<Bool>;
  @:optional var autofocus:HtmlAttribute<Bool>;
  @:optional var autocomplete:HtmlAttribute<String>;
  @:optional var value:HtmlAttribute<String>;
  @:optional var readOnly:HtmlAttribute<Bool>;
  @:html('value') @:optional var defaultValue:HtmlAttribute<String>;
  @:optional var type:HtmlAttribute<InputType>;
  @:optional var name:HtmlAttribute<String>;
  @:optional var placeholder:HtmlAttribute<String>;
  @:optional var max:HtmlAttribute<String>;
  @:optional var min:HtmlAttribute<String>;
  @:optional var step:HtmlAttribute<String>;
  @:optional var maxLength:HtmlAttribute<Int>;
  @:optional var pattern:HtmlAttribute<String>;
  @:optional var accept:HtmlAttribute<String>;
  @:optional var multiple:HtmlAttribute<Bool>;
}

typedef ButtonAttr = GlobalAttr & {
  @:optional var disabled:HtmlAttribute<Bool>;
  @:optional var autofocus:HtmlAttribute<Bool>;
  @:optional var type:HtmlAttribute<String>;
  @:optional var name:HtmlAttribute<String>;
}

typedef TextAreaAttr = GlobalAttr & {
  @:optional var autofocus:HtmlAttribute<Bool>;
  @:optional var cols:HtmlAttribute<Int>;
  @:optional var dirname:HtmlAttribute<String>;
  @:optional var disabled:HtmlAttribute<Bool>;
  @:optional var form:HtmlAttribute<String>;
  @:optional var maxlength:HtmlAttribute<Int>;
  @:optional var name:HtmlAttribute<String>;
  @:optional var placeholder:HtmlAttribute<String>;
  @:optional var readOnly:HtmlAttribute<Bool>;
  @:optional var required:HtmlAttribute<Bool>;
  @:optional var rows:HtmlAttribute<Int>;
  @:optional var value:HtmlAttribute<String>;
  @:optional var defaultValue:HtmlAttribute<String>;
  @:optional var wrap:HtmlAttribute<String>;
}

typedef IFrameAttr = GlobalAttr & {
  @:optional var sandbox:HtmlAttribute<String>;
  @:optional var width:HtmlAttribute<Int>;
  @:optional var height:HtmlAttribute<Int>;
  @:optional var src:HtmlAttribute<String>;
  @:optional var srcdoc:HtmlAttribute<String>;
  @:optional var allowFullscreen:HtmlAttribute<Bool>;
  @:deprecated @:optional var scrolling:HtmlAttribute<IframeScrolling>;
}

enum abstract IframeScrolling(String) {
  var Yes = "yes";
  var No = "no";
  var Auto = "auto";
}

typedef ImageAttr = GlobalAttr & {
  @:optional var src:HtmlAttribute<String>;
  @:optional var width:HtmlAttribute<Int>;
  @:optional var height:HtmlAttribute<Int>;
  @:optional var alt:HtmlAttribute<String>;
  @:optional var srcset:HtmlAttribute<String>;
  @:optional var sizes:HtmlAttribute<String>;
}

private typedef MediaAttr = GlobalAttr & {
  @:optional var src:HtmlAttribute<String>;
  @:optional var autoplay:HtmlAttribute<Bool>;
  @:optional var controls:HtmlAttribute<Bool>;
  @:optional var loop:HtmlAttribute<Bool>;
  @:optional var muted:HtmlAttribute<Bool>;
  @:optional var preload:HtmlAttribute<String>;
  @:optional var volume:HtmlAttribute<Float>;
}

typedef AudioAttr = MediaAttr & {};

typedef VideoAttr = MediaAttr & {
  @:optional var height:HtmlAttribute<Int>;
  @:optional var poster:HtmlAttribute<String>;
  @:optional var width:HtmlAttribute<Int>;
  @:optional var playsInline:HtmlAttribute<Bool>;
}

typedef SourceAttr = GlobalAttr & {
  @:optional var src:HtmlAttribute<String>;
  @:optional var srcset:HtmlAttribute<String>;
  @:optional var media:HtmlAttribute<String>;
  @:optional var sizes:HtmlAttribute<String>;
  @:optional var type:HtmlAttribute<String>;
}

typedef LabelAttr = GlobalAttr & {
  @:html('for') @:optional var htmlFor:HtmlAttribute<String>;
}

typedef SelectAttr = GlobalAttr & {
  @:optional var autofocus:HtmlAttribute<Bool>;
  @:optional var disabled:HtmlAttribute<Bool>;
  @:optional var multiple:HtmlAttribute<Bool>;
  @:optional var value:HtmlAttribute<String>;
  @:optional var name:HtmlAttribute<String>;
  @:optional var required:HtmlAttribute<Bool>;
  @:optional var size:HtmlAttribute<Int>;
}

typedef FormAttr = GlobalAttr & {
  @:optional var method:HtmlAttribute<String>;
  @:optional var action:HtmlAttribute<String>;
}

typedef AnchorAttr = GlobalAttr & {
  @:optional var href:HtmlAttribute<String>;
  @:optional var target:HtmlAttribute<String>;
  @:optional var type:HtmlAttribute<String>;
  @:optional var rel:HtmlAttribute<AnchorRel>;
}

typedef OptionAttr = GlobalAttr & {
  @:optional var disabled:HtmlAttribute<Bool>;
  @:optional var label:HtmlAttribute<String>;
  @:jsOnly @:optional var defaultSelected:HtmlAttribute<Bool>;
  @:optional var selected:HtmlAttribute<Bool>;
  @:optional var value:HtmlAttribute<String>;
  @:optional var text:HtmlAttribute<String>;
  @:optional var index:HtmlAttribute<Int>;
}

typedef MetaAttr = GlobalAttr & {
  @:optional var content:HtmlAttribute<String>;
  @:optional var name:HtmlAttribute<String>;
  @:optional var charset:HtmlAttribute<String>;
  @:optional var httpEquiv:HtmlAttribute<MetaHttpEquiv>;
}

enum abstract MetaHttpEquiv(String) to String from String {
  var ContentType = "content-type";
  var DefaultStyle = "default-style";
  var Refresh = "refresh";
}

typedef LinkAttr = GlobalAttr & {
  var rel:LinkRel;
  @:optional var crossorigin:HtmlAttribute<LinkCrossOrigin>;
  @:optional var href:HtmlAttribute<String>;
  @:optional var hreflang:HtmlAttribute<String>;
  @:optional var media:HtmlAttribute<String>;
  @:optional var sizes:HtmlAttribute<String>;
  @:optional var type:HtmlAttribute<String>;
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
  @:optional var async:HtmlAttribute<Bool>;
  @:optional var charset:HtmlAttribute<String>;
  @:optional var defer:HtmlAttribute<Bool>;
  @:optional var src:HtmlAttribute<String>;
  @:optional var type:HtmlAttribute<String>;
}

typedef StyleAttr = GlobalAttr & {
  @:optional var type:HtmlAttribute<String>;
  @:optional var media:HtmlAttribute<String>;
  @:optional var nonce:HtmlAttribute<String>;
}

typedef CanvasAttr = GlobalAttr & {
  @:optional var width:HtmlAttribute<String>;
  @:optional var height:HtmlAttribute<String>;
}

typedef TrackAttr = {
  var src:HtmlAttribute<String>;
  @:optional var kind:HtmlAttribute<TrackKind>;
  @:optional var label:HtmlAttribute<String>;
  @:optional var srclang:HtmlAttribute<String>;
}

enum abstract TrackKind(String) to String from String {
  var Subtitles = 'subtitles';
  var Captions = 'captions';
  var Descriptions = 'descriptions';
  var Chapters = 'chapters';
  var Metadata = 'metadata';
}

typedef EmbedAttr = {
  var height:HtmlAttribute<Int>;
  var width:HtmlAttribute<Int>;
  var src:HtmlAttribute<String>;
  var typed:HtmlAttribute<String>;
}
