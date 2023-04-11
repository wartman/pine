// @todo: @:html(...) and @:jsOnly currently have no effect.
package pine.html;

import pine.signal.Signal;

// Taken from: https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Aria.hx
typedef AriaAttributes = {
  @:html('aria-label') @:optional final ariaLabel:ReadonlySignal<String>;
  @:html('aria-current') @:optional final ariaCurrent:ReadonlySignal<String>;
  @:html('aria-labeledby') @:optional final ariaLabelledby:ReadonlySignal<String>;
  @:html('aria-describedby') @:optional final ariaDescribedby:ReadonlySignal<String>;
  @:html('aria-autocomplete') @:optional final ariaAutocomplete:ReadonlySignal<String>;
  @:html('aria-dropeffect') @:optional final ariaDropEffect:ReadonlySignal<String>;
  @:html('aria-hidden') @:optional final ariaHidden:ReadonlySignal<Bool>;
  @:html('aria-disabled') @:optional final ariaDisabled:ReadonlySignal<Bool>;
  @:html('aria-checked') @:optional final ariaChecked:ReadonlySignal<Bool>;
  @:html('aria-haspopup') @:optional final ariaHasPopup:ReadonlySignal<Bool>;
  @:html('aria-grabbed') @:optional final ariaGrabbed:ReadonlySignal<Bool>;
  @:html('aria-valuenow') @:optional final ariaValuenow:ReadonlySignal<Float>;
  @:html('aria-valuemin') @:optional final ariaValuemin:ReadonlySignal<Float>;
  @:html('aria-valuemax') @:optional final ariaValuemax:ReadonlySignal<Float>;
  @:html('aria-valuetext') @:optional final ariaValuetext:ReadonlySignal<String>;
  @:html('aria-modal') @:optional final ariaModal:ReadonlySignal<String>;
}

// From https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Attributes.hx
typedef GlobalAttr = AriaAttributes & {
  @:html('class') @:optional var className:ReadonlySignal<String>;
  @:optional var id:ReadonlySignal<String>;
  @:optional var title:ReadonlySignal<String>;
  @:optional var lang:ReadonlySignal<String>;
  @:optional var dir:ReadonlySignal<String>;
  @:optional var contentEditable:ReadonlySignal<Bool>;
  @:optional var inputmode:ReadonlySignal<Bool>;

  @:optional var hidden:ReadonlySignal<Bool>;
  @:optional var tabIndex:ReadonlySignal<Int>;
  @:optional var accessKey:ReadonlySignal<String>;
  @:optional var draggable:ReadonlySignal<Bool>;
  @:optional var spellcheck:ReadonlySignal<Bool>;
  @:optional var style:ReadonlySignal<String>;
  @:optional var role:ReadonlySignal<String>;
}

typedef DetailsAttr = GlobalAttr & {
  @:optional var open:ReadonlySignal<Bool>;
}

typedef FieldSetAttr = GlobalAttr & {
  @:optional var disabled:ReadonlySignal<Bool>;
  @:optional var name:ReadonlySignal<String>;
}

typedef ObjectAttr = GlobalAttr & {
  @:optional var type:ReadonlySignal<String>;
  @:optional var data:ReadonlySignal<String>;
  @:optional var width:ReadonlySignal<Int>;
  @:optional var height:ReadonlySignal<Int>;
}

typedef ParamAttr = GlobalAttr & {
  var name:ReadonlySignal<String>;
  var value:ReadonlySignal<String>;
}

typedef TableCellAttr = GlobalAttr & {
  @:optional var abbr:ReadonlySignal<String>;
  @:optional var colSpan:ReadonlySignal<Int>;
  @:optional var headers:ReadonlySignal<String>;
  @:optional var rowSpan:ReadonlySignal<Int>;
  @:optional var scope:ReadonlySignal<String>;
  @:optional var sorted:ReadonlySignal<String>;
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
  @:optional var checked:ReadonlySignal<Bool>;
  @:optional var disabled:ReadonlySignal<Bool>;
  @:optional var required:ReadonlySignal<Bool>;
  @:optional var autofocus:ReadonlySignal<Bool>;
  @:optional var autocomplete:ReadonlySignal<String>;
  @:optional var value:ReadonlySignal<String>;
  @:optional var readOnly:ReadonlySignal<Bool>;
  @:html('value') @:optional var defaultValue:ReadonlySignal<String>;
  @:optional var type:ReadonlySignal<InputType>;
  @:optional var name:ReadonlySignal<String>;
  @:optional var placeholder:ReadonlySignal<String>;
  @:optional var max:ReadonlySignal<String>;
  @:optional var min:ReadonlySignal<String>;
  @:optional var step:ReadonlySignal<String>;
  @:optional var maxLength:ReadonlySignal<Int>;
  @:optional var pattern:ReadonlySignal<String>;
  @:optional var accept:ReadonlySignal<String>;
  @:optional var multiple:ReadonlySignal<Bool>;
}

typedef ButtonAttr = GlobalAttr & {
  @:optional var disabled:ReadonlySignal<Bool>;
  @:optional var autofocus:ReadonlySignal<Bool>;
  @:optional var type:ReadonlySignal<String>;
  @:optional var name:ReadonlySignal<String>;
}

typedef TextAreaAttr = GlobalAttr & {
  @:optional var autofocus:ReadonlySignal<Bool>;
  @:optional var cols:ReadonlySignal<Int>;
  @:optional var dirname:ReadonlySignal<String>;
  @:optional var disabled:ReadonlySignal<Bool>;
  @:optional var form:ReadonlySignal<String>;
  @:optional var maxlength:ReadonlySignal<Int>;
  @:optional var name:ReadonlySignal<String>;
  @:optional var placeholder:ReadonlySignal<String>;
  @:optional var readOnly:ReadonlySignal<Bool>;
  @:optional var required:ReadonlySignal<Bool>;
  @:optional var rows:ReadonlySignal<Int>;
  @:optional var value:ReadonlySignal<String>;
  @:optional var defaultValue:ReadonlySignal<String>;
  @:optional var wrap:ReadonlySignal<String>;
}

typedef IFrameAttr = GlobalAttr & {
  @:optional var sandbox:ReadonlySignal<String>;
  @:optional var width:ReadonlySignal<Int>;
  @:optional var height:ReadonlySignal<Int>;
  @:optional var src:ReadonlySignal<String>;
  @:optional var srcdoc:ReadonlySignal<String>;
  @:optional var allowFullscreen:ReadonlySignal<Bool>;
  @:deprecated @:optional var scrolling:ReadonlySignal<IframeScrolling>;
}

enum abstract IframeScrolling(String) {
  var Yes = "yes";
  var No = "no";
  var Auto = "auto";
}

typedef ImageAttr = GlobalAttr & {
  @:optional var src:ReadonlySignal<String>;
  @:optional var width:ReadonlySignal<Int>;
  @:optional var height:ReadonlySignal<Int>;
  @:optional var alt:ReadonlySignal<String>;
  @:optional var srcset:ReadonlySignal<String>;
  @:optional var sizes:ReadonlySignal<String>;
}

private typedef MediaAttr = GlobalAttr & {
  @:optional var src:ReadonlySignal<String>;
  @:optional var autoplay:ReadonlySignal<Bool>;
  @:optional var controls:ReadonlySignal<Bool>;
  @:optional var loop:ReadonlySignal<Bool>;
  @:optional var muted:ReadonlySignal<Bool>;
  @:optional var preload:ReadonlySignal<String>;
  @:optional var volume:ReadonlySignal<Float>;
}

typedef AudioAttr = MediaAttr & {};

typedef VideoAttr = MediaAttr & {
  @:optional var height:ReadonlySignal<Int>;
  @:optional var poster:ReadonlySignal<String>;
  @:optional var width:ReadonlySignal<Int>;
  @:optional var playsInline:ReadonlySignal<Bool>;
}

typedef SourceAttr = GlobalAttr & {
  @:optional var src:ReadonlySignal<String>;
  @:optional var srcset:ReadonlySignal<String>;
  @:optional var media:ReadonlySignal<String>;
  @:optional var sizes:ReadonlySignal<String>;
  @:optional var type:ReadonlySignal<String>;
}

typedef LabelAttr = GlobalAttr & {
  @:html('for') @:optional var htmlFor:ReadonlySignal<String>;
}

typedef SelectAttr = GlobalAttr & {
  @:optional var autofocus:ReadonlySignal<Bool>;
  @:optional var disabled:ReadonlySignal<Bool>;
  @:optional var multiple:ReadonlySignal<Bool>;
  @:optional var value:ReadonlySignal<String>;
  @:optional var name:ReadonlySignal<String>;
  @:optional var required:ReadonlySignal<Bool>;
  @:optional var size:ReadonlySignal<Int>;
}

typedef FormAttr = GlobalAttr & {
  @:optional var method:ReadonlySignal<String>;
  @:optional var action:ReadonlySignal<String>;
}

typedef AnchorAttr = GlobalAttr & {
  @:optional var href:ReadonlySignal<String>;
  @:optional var target:ReadonlySignal<String>;
  @:optional var type:ReadonlySignal<String>;
  @:optional var rel:ReadonlySignal<AnchorRel>;
}

typedef OptionAttr = GlobalAttr & {
  @:optional var disabled:ReadonlySignal<Bool>;
  @:optional var label:ReadonlySignal<String>;
  @:jsOnly @:optional var defaultSelected:ReadonlySignal<Bool>;
  @:optional var selected:ReadonlySignal<Bool>;
  @:optional var value:ReadonlySignal<String>;
  @:optional var text:ReadonlySignal<String>;
  @:optional var index:ReadonlySignal<Int>;
}

typedef MetaAttr = GlobalAttr & {
  @:optional var content:ReadonlySignal<String>;
  @:optional var name:ReadonlySignal<String>;
  @:optional var charset:ReadonlySignal<String>;
  @:optional var httpEquiv:ReadonlySignal<MetaHttpEquiv>;
}

enum abstract MetaHttpEquiv(String) to String from String {
  var ContentType = "content-type";
  var DefaultStyle = "default-style";
  var Refresh = "refresh";
}

typedef LinkAttr = GlobalAttr & {
  var rel:LinkRel;
  @:optional var crossorigin:ReadonlySignal<LinkCrossOrigin>;
  @:optional var href:ReadonlySignal<String>;
  @:optional var hreflang:ReadonlySignal<String>;
  @:optional var media:ReadonlySignal<String>;
  @:optional var sizes:ReadonlySignal<String>;
  @:optional var type:ReadonlySignal<String>;
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
  @:optional var async:ReadonlySignal<Bool>;
  @:optional var charset:ReadonlySignal<String>;
  @:optional var defer:ReadonlySignal<Bool>;
  @:optional var src:ReadonlySignal<String>;
  @:optional var type:ReadonlySignal<String>;
}

typedef StyleAttr = GlobalAttr & {
  @:optional var type:ReadonlySignal<String>;
  @:optional var media:ReadonlySignal<String>;
  @:optional var nonce:ReadonlySignal<String>;
}

typedef CanvasAttr = GlobalAttr & {
  @:optional var width:ReadonlySignal<String>;
  @:optional var height:ReadonlySignal<String>;
}

typedef TrackAttr = {
  var src:ReadonlySignal<String>;
  @:optional var kind:ReadonlySignal<TrackKind>;
  @:optional var label:ReadonlySignal<String>;
  @:optional var srclang:ReadonlySignal<String>;
}

enum abstract TrackKind(String) to String from String {
  var Subtitles = 'subtitles';
  var Captions = 'captions';
  var Descriptions = 'descriptions';
  var Chapters = 'chapters';
  var Metadata = 'metadata';
}

typedef EmbedAttr = {
  var height:ReadonlySignal<Int>;
  var width:ReadonlySignal<Int>;
  var src:ReadonlySignal<String>;
  var typed:ReadonlySignal<String>;
}
