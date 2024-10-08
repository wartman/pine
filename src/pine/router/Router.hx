package pine.router;

import kit.http.Request;
import pine.signal.Observer;

class Router extends Component {
	@:attribute final routes:Array<Matchable>;
	@:attribute final fallback:(request:Request) -> Child;

	function render():Child {
		var nav = Navigator.from(this);
		return Scope.wrap(() -> {
			var request = nav.request();
			for (route in routes) switch route.match(request) {
				case Some(render): return Observer.untrack(render);
				case None:
			}
			return fallback(request);
		});
	}
}
