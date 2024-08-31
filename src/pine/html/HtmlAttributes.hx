package pine.html;

// Taken from: https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Aria.hx
typedef AriaAttributes = {
	@:attr('aria-label') var ?ariaLabel:String;
	@:attr('aria-current') var ?ariaCurrent:String;
	@:attr('aria-labeledby') var ?ariaLabelledby:String;
	@:attr('aria-describedby') var ?ariaDescribedby:String;
	@:attr('aria-autocomplete') var ?ariaAutocomplete:String;
	@:attr('aria-dropeffect') var ?ariaDropEffect:String;
	@:attr('aria-hidden') var ?ariaHidden:Bool;
	@:attr('aria-disabled') var ?ariaDisabled:Bool;
	@:attr('aria-checked') var ?ariaChecked:Bool;
	@:attr('aria-haspopup') var ?ariaHasPopup:Bool;
	@:attr('aria-grabbed') var ?ariaGrabbed:Bool;
	@:attr('aria-valuenow') var ?ariaValuenow:Float;
	@:attr('aria-valuemin') var ?ariaValuemin:Float;
	@:attr('aria-valuemax') var ?ariaValuemax:Float;
	@:attr('aria-valuetext') var ?ariaValuetext:String;
	@:attr('aria-modal') var ?ariaModal:String;
}

// From https://github.com/haxetink/tink_domspec/blob/master/src/tink/domspec/Attributes.hx
typedef GlobalAttr = AriaAttributes & {
	@:attr('class') var ?className:String;
	var ?id:String;
	var ?title:String;
	var ?lang:String;
	var ?dir:String;
	var ?contentEditable:Bool;
	var ?inputMode:Bool;
	var ?hidden:Bool;
	var ?tabIndex:Int;
	var ?accessKey:String;
	var ?draggable:Bool;
	var ?spellcheck:Bool;
	var ?style:String;
	var ?role:String;
	var ?dataset:Map<String, String>;
}

typedef DetailsAttr = GlobalAttr & {
	var ?open:Bool;
}

typedef FieldSetAttr = GlobalAttr & {
	var ?disabled:Bool;
	var ?name:String;
}

typedef ObjectAttr = GlobalAttr & {
	var ?type:String;
	var ?data:String;
	var ?width:Int;
	var ?height:Int;
}

typedef ParamAttr = GlobalAttr & {
	var name:String;
	var value:String;
}

typedef TableCellAttr = GlobalAttr & {
	var ?abbr:String;
	var ?colSpan:Int;
	var ?headers:String;
	var ?rowSpan:Int;
	var ?scope:String;
	var ?sorted:String;
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
	var ?checked:Bool;
	var ?disabled:Bool;
	var ?required:Bool;
	var ?autofocus:Bool;
	var ?autocomplete:String;
	var ?value:String;
	var ?readOnly:Bool;
	@:attr('value') var ?defaultValue:String;
	var ?type:InputType;
	var ?name:String;
	var ?placeholder:String;
	var ?max:String;
	var ?min:String;
	var ?step:String;
	var ?maxLength:Int;
	var ?pattern:String;
	var ?accept:String;
	var ?multiple:Bool;
}

typedef ButtonAttr = GlobalAttr & {
	var ?disabled:Bool;
	var ?autofocus:Bool;
	var ?type:String;
	var ?name:String;
}

typedef TextAreaAttr = GlobalAttr & {
	var ?autofocus:Bool;
	var ?cols:Int;
	var ?dirname:String;
	var ?disabled:Bool;
	var ?form:String;
	var ?maxlength:Int;
	var ?name:String;
	var ?placeholder:String;
	var ?readOnly:Bool;
	var ?required:Bool;
	var ?rows:Int;
	var ?value:String;
	var ?defaultValue:String;
	var ?wrap:String;
}

typedef IFrameAttr = GlobalAttr & {
	var ?sandbox:String;
	var ?width:Int;
	var ?height:Int;
	var ?src:String;
	var ?srcdoc:String;
	var ?allowFullscreen:Bool;
	@:deprecated var ?scrolling:IframeScrolling;
}

enum abstract IframeScrolling(String) {
	var Yes = "yes";
	var No = "no";
	var Auto = "auto";
}

typedef ImageAttr = GlobalAttr & {
	var ?src:String;
	var ?width:Int;
	var ?height:Int;
	var ?alt:String;
	var ?srcset:String;
	var ?sizes:String;
}

private typedef MediaAttr = GlobalAttr & {
	var ?src:String;
	var ?autoplay:Bool;
	var ?controls:Bool;
	var ?loop:Bool;
	var ?muted:Bool;
	var ?preload:String;
	var ?volume:Float;
}

typedef AudioAttr = MediaAttr & {};

typedef VideoAttr = MediaAttr & {
	var ?height:Int;
	var ?poster:String;
	var ?width:Int;
	var ?playsInline:Bool;
}

typedef SourceAttr = GlobalAttr & {
	var ?src:String;
	var ?srcset:String;
	var ?media:String;
	var ?sizes:String;
	var ?type:String;
}

typedef LabelAttr = GlobalAttr & {
	@:attr('for') var ?htmlFor:String;
}

typedef SelectAttr = GlobalAttr & {
	var ?autofocus:Bool;
	var ?disabled:Bool;
	var ?multiple:Bool;
	var ?value:String;
	var ?name:String;
	var ?required:Bool;
	var ?size:Int;
}

typedef FormAttr = GlobalAttr & {
	var ?method:String;
	var ?action:String;
}

typedef AnchorAttr = GlobalAttr & {
	var ?href:String;
	var ?target:String;
	var ?type:String;
	var ?rel:AnchorRel;
}

typedef OptionAttr = GlobalAttr & {
	var ?disabled:Bool;
	var ?label:String;
	@:jsOnly var ?defaultSelected:Bool;
	var ?selected:Bool;
	var ?value:String;
	var ?text:String;
	var ?index:Int;
}

typedef MetaAttr = GlobalAttr & {
	var ?content:String;
	var ?name:String;
	var ?charset:String;
	var ?httpEquiv:MetaHttpEquiv;
}

enum abstract MetaHttpEquiv(String) to String from String {
	var ContentType = "content-type";
	var DefaultStyle = "default-style";
	var Refresh = "refresh";
}

typedef LinkAttr = GlobalAttr & {
	var rel:LinkRel;
	var ?crossorigin:LinkCrossOrigin;
	var ?href:String;
	var ?hreflang:String;
	var ?media:String;
	var ?sizes:String;
	var ?type:String;
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
	var ?async:Bool;
	var ?charset:String;
	var ?defer:Bool;
	var ?src:String;
	var ?type:String;
}

typedef StyleAttr = GlobalAttr & {
	var ?type:String;
	var ?media:String;
	var ?nonce:String;
}

typedef CanvasAttr = GlobalAttr & {
	var ?width:String;
	var ?height:String;
}

typedef TrackAttr = {
	var src:String;
	var ?kind:TrackKind;
	var ?label:String;
	var ?srclang:String;
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
