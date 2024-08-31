package pine.parse;

import pine.parse.Attribute;
import pine.parse.Node;
import haxe.macro.Context;
import haxe.macro.Expr;

using kit.macro.Tools;
using haxe.macro.Tools;

typedef ParserOptions = {
	public final generateExpr:(nodes:Array<Node>) -> Expr;
}

// @todo: this should really use char codes, not strings
// @todo: Something I'm doing here (parseInlineString?) is killing
// completion. May also be happening in the Generator.
class Parser {
	final source:Source;
	final options:ParserOptions;

	var position:Int = 0;

	public function new(source, options) {
		this.source = source;
		this.options = options;
	}

	public function toExpr() {
		var expr = options.generateExpr(parse());
		var pos = createPos(0, position);
		return macro @:pos(pos) ($expr : pine.Child);
	}

	public function parse():Array<Node> {
		position = 0;

		var nodes:Array<Node> = [];

		try while (!isAtEnd()) {
			whitespace();
			nodes.push(parseRoot());
		} catch (e:ParserException) {
			e.pos.error(e.message);
		}

		return nodes;
	}

	function parseRoot() {
		whitespace();
		if (match('</')) errorAt(ParserException.unexpectedCloseTag, '</');
		if (match('<')) return parseNode();
		return parseExpr();
	}

	function parseNode():Node {
		var start = position - 1;

		whitespace();

		if (match('>')) return parseFragment();

		var tag = tag();
		var attributes:Array<Attribute> = [];
		var children:Array<Node> = [];

		whitespace();

		while (!checkAny('>', '/>') && !isAtEnd()) {
			whitespace();

			var name = identifier();

			if (name.value.length == 0) errorAt(ParserException.expectedIdentifier, peek());

			whitespace();

			var value:Expr = if (match('=')) {
				whitespace();
				expression();
			} else macro true;

			whitespace();

			attributes.push({
				name: name,
				value: value
			});
		}

		whitespace();

		if (!match('/>')) {
			consume('>');
			children = parseChildren(tag.value);
		}

		return {
			value: NNode(tag, attributes, children),
			pos: createPos(start, position)
		};
	}

	function parseChildren(closeTag:String):Array<Node> {
		var start = position;
		var children:Array<Node> = [];

		whitespace();

		while (!isAtEnd() && !check('</')) {
			var n = parseRoot();
			if (n != null) children.push(n);
			whitespace();
		}

		consume('</');
		whitespace();

		var matched = tag();
		if (matched.value != closeTag) {
			error('Expected close tag to be </$closeTag>', matched.pos);
		}

		whitespace();
		consume('>');

		return children;
	}

	function parseExpr():Node {
		var expr = switch expression() {
			case null: macro null;
			case expr: expr;
		}

		return {
			value: NExpr(expr),
			pos: expr.pos
		};
	}

	function parseFragment():Node {
		var start = position;
		var children = parseChildren('');
		return {
			value: NFragment(children),
			pos: createPos(start, position)
		}
	}

	function tag():Located<String> {
		var start = position;
		var parts = path();
		if (parts.length == 0) expected('Identifier');
		return {
			value: parts.map(p -> p.value).join('.'),
			pos: createPos(start, position)
		};
	}

	function expression():Expr {
		var start = position;

		if (match('{')) {
			var exprStr = extractDelimitedString('{', '}');
			var expr = stringToExpression(exprStr);
			var pos = createPos(start, position);
			return expr.at(pos);
		}

		if (match('"')) {
			var str = extractDelimitedString('"', '"', true);
			var pos = createPos(start, position);
			return macro @:pos(pos) $v{str.value};
		}

		if (match("'")) {
			var str = extractDelimitedString("'", "'", true);
			// Note: this is to allow for interpolation in single-quoted strings.
			var pos = createPos(start, position);
			var expr = stringToExpression({
				value: "'" + str.value + "'",
				pos: pos
			});
			return expr.at(pos);
		}

		if (isAlpha(peek())) {
			var located = path();
			return macro @:pos(located.pos) $p{located.map(p -> p.value)};
		}

		if (isDigit(peek())) {
			var located = number();
			return macro @:pos(located.pos) $v{located.value};
		}

		reject(peek());
		return null;
	}

	function stringToExpression(exprStr:Located<String>):Expr {
		try return reenter(Context.parseInlineString(exprStr.value, exprStr.pos)) catch (e) {
			exprStr.pos.error(e.message);
			return macro null;
		}
	}

	function reenter(e:Expr):Expr {
		return switch e {
			case macro @:markup ${
				{expr: EConst(CString(_))}
			}:
				new Parser(e, options).toExpr();
			default:
				e.map(reenter);
		}
	}

	function extractDelimitedString(startToken:String, endToken:String, escapable:Bool = false):Located<String> {
		var start = position;
		var depth = 1;

		while (!isAtEnd() && depth > 0) {
			if (escapable && (match('\\${startToken}') || match('\\${endToken}'))) {
				advance();
				continue;
			}

			if (check(endToken)) {
				depth--;
				if (depth == 0) break else {
					advance();
					continue;
				}
			}

			if (match(startToken)) {
				depth++;
				continue;
			}

			advance();
		}

		if (isAtEnd()) error('Unterminated value.', createPos(start, position));

		var value = source.content.substring(start, position);
		var pos = createPos(start, position - 1);

		consume(endToken);

		return {
			value: value,
			pos: pos
		};
	}

	function path():Array<Located<String>> {
		var parts = [identifier()];
		while (!isAtEnd() && match('.')) {
			var ident = identifier();
			if (ident == null) errorAt('Expected an identifier', peek());
			parts.push(ident);
		}
		if (parts.length == 0) {
			errorAt('Expected an identifier', peek());
		}
		return parts;
	}

	function identifier():Located<String> {
		var start = position;
		var value = readWhile(() -> isIdentifier(peek()));
		return {
			value: value,
			pos: createPos(start, position)
		};
	}

	function number():Located<String> {
		var start = position;
		var value = readWhile(() -> isDigit(peek()) || check('.'));
		return {
			value: value,
			pos: createPos(start, position)
		};
	}

	function isIdentifier(s:String) {
		return isAlphaNumeric(s) || check('_');
	}

	function isTypeIdentifier(s:String) {
		return isUcAlpha(s);
	}

	function whitespace():Void {
		readWhile(() -> isWhitespace(peek()));
		// Comments
		if (match('//')) {
			readWhile(() -> peek() != '\n');
			return whitespace();
		}
		if (match('/*')) {
			extractDelimitedString('/*', '*/');
			return whitespace();
		}
	}

	function isWhitespace(c:String) {
		return c == ' ' || c == '\n' || c == '\r' || c == '\t';
	}

	function isDigit(c:String):Bool {
		return c >= '0' && c <= '9';
	}

	function isUcAlpha(c:String):Bool {
		return (c >= 'A' && c <= 'Z');
	}

	function isAlpha(c:String):Bool {
		return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
	}

	function isAlphaNumeric(c:String) {
		return isAlpha(c) || isDigit(c);
	}

	function readWhile(compare:() -> Bool):String {
		var out = [while (!isAtEnd() && compare()) advance()];
		return out.join('');
	}

	function ignore(...names:String) {
		for (name in names) match(name);
	}

	function match(value:String) {
		if (check(value)) {
			position = position + value.length;
			return true;
		}
		return false;
	}

	function matchAny(...values:String) {
		for (v in values) {
			if (match(v)) return true;
		}
		return false;
	}

	function check(value:String) {
		var found = source.content.substr(position, value.length);
		return found == value;
	}

	function checkAny(...values:String) {
		for (v in values) {
			if (check(v)) return true;
		}
		return false;
	}

	function checkAnyUnescaped(...items:String) {
		for (item in items) {
			if (check(item)) {
				if (previous() == '\\') return false;
				return true;
			}
		}
		return false;
	}

	function consume(value:String) {
		if (!match(value)) throw expected(value);
	}

	function peek() {
		return source.content.charAt(position);
	}

	function advance() {
		if (!isAtEnd()) position++;
		return previous();
	}

	function previous() {
		return source.content.charAt(position - 1);
	}

	function isAtEnd() {
		return position == source.content.length;
	}

	function createPos(min:Int, max:Int) {
		return Context.makePosition({
			min: source.offset + min,
			max: source.offset + max,
			file: source.file
		});
	}

	function error(msg:String, pos:Position) {
		throw new ParserException(msg, pos);
	}

	function errorAt(msg:String, value:String) {
		throw error(msg, createPos(position - value.length, position));
	}

	function reject(s:String) {
		throw error('Unexpected [${s}]', createPos(position - s.length, position));
	}

	function expected(s:String) {
		throw error('Expected [${s}]', createPos(position, position + 1));
	}
}
