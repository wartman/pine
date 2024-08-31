package pine.parse;

import haxe.macro.Expr;
import haxe.Exception;

class ParserException extends Exception {
	static public final unexpectedCloseTag = 'Unexpected close tag';
	static public final expectedIdentifier = 'Expected an identifier';

	public final pos:Position;

	public function new(message, pos) {
		super(message);
		this.pos = pos;
	}
}
