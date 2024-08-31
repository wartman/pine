package pine.bridge;

using StringTools;
using haxe.io.Path;

class HtmlAsset implements Asset {
	final path:String;
	final html:String;

	public function new(path, html) {
		this.path = path;
		this.html = html;
	}

	public function getIdentifier():Null<String> {
		return '__pine.html<${path}>';
	}

	public function process(context:AppContext):Task<Nothing> {
		var path = path.trim().normalize();
		if (path.startsWith('/')) path = path.substr(1);
		var url = Path.join([path, 'index.html']);
		var file = context.output.file(url);

		return file.write('<!doctype html>' + html);
	}
}
