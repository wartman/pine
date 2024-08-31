package site.page;

import pine.bridge.ServerComponent;
import site.layout.MainLayout;
import site.component.post.*;
import site.component.core.*;

class PostPage extends ServerComponent {
	@:attribute final id:Int;

	function render():Task<Child> {
		return view(<MainLayout title={'Post | ${id}'}>
			<Section constrain>
				<SinglePost id=id />
			</Section>
		</MainLayout>);
	}
}
