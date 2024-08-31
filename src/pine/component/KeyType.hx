package pine.component;

enum abstract KeyType(String) from String {
	final Alt;
	final CapsLock;
	final Control;
	final Fn;
	final FnLock;
	final Hyper;
	final Meta;
	final NumLock;
	final ScrollLock;
	final Shift;
	final Super;
	final Symbol;
	final SymbolLock;
	final Escape;
	final Enter;
	final Tab;
	final Space = ' ';
	final ArrowDown;
	final ArrowUp;
	final ArrowLeft;
	final ArrowRight;
	final End;
	final Home;
	final PageDown;
	final PageUp;
	final Backspace;
	// @todo: Add the rest of this stuff
}
