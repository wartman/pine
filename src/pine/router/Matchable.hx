package pine.router;

import kit.http.Request;

interface Matchable {
	public function match(request:Request):Maybe<() -> Child>;
}
