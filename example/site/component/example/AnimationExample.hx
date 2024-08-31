package site.component.example;

using pine.component.AnimationModifier;

class AnimationExample extends Component {
	function render():Child {
		return Html.div()
			.style(Breeze.compose(
				Background.color('red', 500),
				Sizing.height('30px'),
				Sizing.width('30px')
			))
			.build()
			.withInfiniteAnimation('auto', _ -> [{
				transform: 'rotate(0)'
			}, {transform: 'rotate(360deg)'}], {duration: 1000});
	}
}
