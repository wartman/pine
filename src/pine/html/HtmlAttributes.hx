// @todo: @:html(...) and @:jsOnly currently have no effect.
package pine.html;

import pine.signal.Signal;

// Taken from: https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Aria.hx
typedef AriaAttributes = {
  @:html('aria-label') var ?ariaLabel:ReadonlySignal<String>;
  @:html('aria-current') var ?ariaCurrent:ReadonlySignal<String>;
  @:html('aria-labeledby') var ?ariaLabelledby:ReadonlySignal<String>;
  @:html('aria-describedby') var ?ariaDescribedby:ReadonlySignal<String>;
  @:html('aria-autocomplete') var ?ariaAutocomplete:ReadonlySignal<String>;
  @:html('aria-dropeffect') var ?ariaDropEffect:ReadonlySignal<String>;
  @:html('aria-hidden') var ?ariaHidden:ReadonlySignal<Bool>;
  @:html('aria-disabled') var ?ariaDisabled:ReadonlySignal<Bool>;
  @:html('aria-checked') var ?ariaChecked:ReadonlySignal<Bool>;
  @:html('aria-haspopup') var ?ariaHasPopup:ReadonlySignal<Bool>;
  @:html('aria-grabbed') var ?ariaGrabbed:ReadonlySignal<Bool>;
  @:html('aria-valuenow') var ?ariaValuenow:ReadonlySignal<Float>;
  @:html('aria-valuemin') var ?ariaValuemin:ReadonlySignal<Float>;
  @:html('aria-valuemax') var ?ariaValuemax:ReadonlySignal<Float>;
  @:html('aria-valuetext') var ?ariaValuetext:ReadonlySignal<String>;
  @:html('aria-modal') var ?ariaModal:ReadonlySignal<String>;
}

// From https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Attributes.hx
typedef GlobalAttr = AriaAttributes & {
  @:html('class') var ?className:ReadonlySignal<String>;
  var ?id:ReadonlySignal<String>;
  var ?title:ReadonlySignal<String>;
  var ?lang:ReadonlySignal<String>;
  var ?dir:ReadonlySignal<String>;
  var ?contentEditable:ReadonlySignal<Bool>;
  var ?inputmode:ReadonlySignal<Bool>;

  var ?hidden:ReadonlySignal<Bool>;
  var ?tabIndex:ReadonlySignal<Int>;
  var ?accessKey:ReadonlySignal<String>;
  var ?draggable:ReadonlySignal<Bool>;
  var ?spellcheck:ReadonlySignal<Bool>;
  var ?style:ReadonlySignal<String>;
  var ?role:ReadonlySignal<String>;
}

typedef DetailsAttr = GlobalAttr & {
  var ?open:ReadonlySignal<Bool>;
}

typedef FieldSetAttr = GlobalAttr & {
  var ?disabled:ReadonlySignal<Bool>;
  var ?name:ReadonlySignal<String>;
}

typedef ObjectAttr = GlobalAttr & {
  var ?type:ReadonlySignal<String>;
  var ?data:ReadonlySignal<String>;
  var ?width:ReadonlySignal<Int>;
  var ?height:ReadonlySignal<Int>;
}

typedef ParamAttr = GlobalAttr & {
  var name:ReadonlySignal<String>;
  var value:ReadonlySignal<String>;
}

typedef TableCellAttr = GlobalAttr & {
  var ?abbr:ReadonlySignal<String>;
  var ?colSpan:ReadonlySignal<Int>;
  var ?headers:ReadonlySignal<String>;
  var ?rowSpan:ReadonlySignal<Int>;
  var ?scope:ReadonlySignal<String>;
  var ?sorted:ReadonlySignal<String>;
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
  var ?checked:ReadonlySignal<Bool>;
  var ?disabled:ReadonlySignal<Bool>;
  var ?required:ReadonlySignal<Bool>;
  var ?autofocus:ReadonlySignal<Bool>;
  var ?autocomplete:ReadonlySignal<String>;
  var ?value:ReadonlySignal<String>;
  var ?readOnly:ReadonlySignal<Bool>;
  @:html('value') var ?defaultValue:ReadonlySignal<String>;
  var ?type:ReadonlySignal<InputType>;
  var ?name:ReadonlySignal<String>;
  var ?placeholder:ReadonlySignal<String>;
  var ?max:ReadonlySignal<String>;
  var ?min:ReadonlySignal<String>;
  var ?step:ReadonlySignal<String>;
  var ?maxLength:ReadonlySignal<Int>;
  var ?pattern:ReadonlySignal<String>;
  var ?accept:ReadonlySignal<String>;
  var ?multiple:ReadonlySignal<Bool>;
}

typedef ButtonAttr = GlobalAttr & {
  var ?disabled:ReadonlySignal<Bool>;
  var ?autofocus:ReadonlySignal<Bool>;
  var ?type:ReadonlySignal<String>;
  var ?name:ReadonlySignal<String>;
}

typedef TextAreaAttr = GlobalAttr & {
  var ?autofocus:ReadonlySignal<Bool>;
  var ?cols:ReadonlySignal<Int>;
  var ?dirname:ReadonlySignal<String>;
  var ?disabled:ReadonlySignal<Bool>;
  var ?form:ReadonlySignal<String>;
  var ?maxlength:ReadonlySignal<Int>;
  var ?name:ReadonlySignal<String>;
  var ?placeholder:ReadonlySignal<String>;
  var ?readOnly:ReadonlySignal<Bool>;
  var ?required:ReadonlySignal<Bool>;
  var ?rows:ReadonlySignal<Int>;
  var ?value:ReadonlySignal<String>;
  var ?defaultValue:ReadonlySignal<String>;
  var ?wrap:ReadonlySignal<String>;
}

typedef IFrameAttr = GlobalAttr & {
  var ?sandbox:ReadonlySignal<String>;
  var ?width:ReadonlySignal<Int>;
  var ?height:ReadonlySignal<Int>;
  var ?src:ReadonlySignal<String>;
  var ?srcdoc:ReadonlySignal<String>;
  var ?allowFullscreen:ReadonlySignal<Bool>;
  @:deprecated var ?scrolling:ReadonlySignal<IframeScrolling>;
}

enum abstract IframeScrolling(String) {
  var Yes = "yes";
  var No = "no";
  var Auto = "auto";
}

typedef ImageAttr = GlobalAttr & {
  var ?src:ReadonlySignal<String>;
  var ?width:ReadonlySignal<Int>;
  var ?height:ReadonlySignal<Int>;
  var ?alt:ReadonlySignal<String>;
  var ?srcset:ReadonlySignal<String>;
  var ?sizes:ReadonlySignal<String>;
}

private typedef MediaAttr = GlobalAttr & {
  var ?src:ReadonlySignal<String>;
  var ?autoplay:ReadonlySignal<Bool>;
  var ?controls:ReadonlySignal<Bool>;
  var ?loop:ReadonlySignal<Bool>;
  var ?muted:ReadonlySignal<Bool>;
  var ?preload:ReadonlySignal<String>;
  var ?volume:ReadonlySignal<Float>;
}

typedef AudioAttr = MediaAttr & {};

typedef VideoAttr = MediaAttr & {
  var ?height:ReadonlySignal<Int>;
  var ?poster:ReadonlySignal<String>;
  var ?width:ReadonlySignal<Int>;
  var ?playsInline:ReadonlySignal<Bool>;
}

typedef SourceAttr = GlobalAttr & {
  var ?src:ReadonlySignal<String>;
  var ?srcset:ReadonlySignal<String>;
  var ?media:ReadonlySignal<String>;
  var ?sizes:ReadonlySignal<String>;
  var ?type:ReadonlySignal<String>;
}

typedef LabelAttr = GlobalAttr & {
  @:html('for') var ?htmlFor:ReadonlySignal<String>;
}

typedef SelectAttr = GlobalAttr & {
  var ?autofocus:ReadonlySignal<Bool>;
  var ?disabled:ReadonlySignal<Bool>;
  var ?multiple:ReadonlySignal<Bool>;
  var ?value:ReadonlySignal<String>;
  var ?name:ReadonlySignal<String>;
  var ?required:ReadonlySignal<Bool>;
  var ?size:ReadonlySignal<Int>;
}

typedef FormAttr = GlobalAttr & {
  var ?method:ReadonlySignal<String>;
  var ?action:ReadonlySignal<String>;
}

typedef AnchorAttr = GlobalAttr & {
  var ?href:ReadonlySignal<String>;
  var ?target:ReadonlySignal<String>;
  var ?type:ReadonlySignal<String>;
  var ?rel:ReadonlySignal<AnchorRel>;
}

typedef OptionAttr = GlobalAttr & {
  var ?disabled:ReadonlySignal<Bool>;
  var ?label:ReadonlySignal<String>;
  @:jsOnly var ?defaultSelected:ReadonlySignal<Bool>;
  var ?selected:ReadonlySignal<Bool>;
  var ?value:ReadonlySignal<String>;
  var ?text:ReadonlySignal<String>;
  var ?index:ReadonlySignal<Int>;
}

typedef MetaAttr = GlobalAttr & {
  var ?content:ReadonlySignal<String>;
  var ?name:ReadonlySignal<String>;
  var ?charset:ReadonlySignal<String>;
  var ?httpEquiv:ReadonlySignal<MetaHttpEquiv>;
}

enum abstract MetaHttpEquiv(String) to String from String {
  var ContentType = "content-type";
  var DefaultStyle = "default-style";
  var Refresh = "refresh";
}

typedef LinkAttr = GlobalAttr & {
  var rel:LinkRel;
  var ?crossorigin:ReadonlySignal<LinkCrossOrigin>;
  var ?href:ReadonlySignal<String>;
  var ?hreflang:ReadonlySignal<String>;
  var ?media:ReadonlySignal<String>;
  var ?sizes:ReadonlySignal<String>;
  var ?type:ReadonlySignal<String>;
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
  var ?async:ReadonlySignal<Bool>;
  var ?charset:ReadonlySignal<String>;
  var ?defer:ReadonlySignal<Bool>;
  var ?src:ReadonlySignal<String>;
  var ?type:ReadonlySignal<String>;
}

typedef StyleAttr = GlobalAttr & {
  var ?type:ReadonlySignal<String>;
  var ?media:ReadonlySignal<String>;
  var ?nonce:ReadonlySignal<String>;
}

typedef CanvasAttr = GlobalAttr & {
  var ?width:ReadonlySignal<String>;
  var ?height:ReadonlySignal<String>;
}

typedef TrackAttr = {
  var src:ReadonlySignal<String>;
  var ?kind:ReadonlySignal<TrackKind>;
  var ?label:ReadonlySignal<String>;
  var ?srclang:ReadonlySignal<String>;
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
