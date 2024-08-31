package pine.component;

using pine.Modifier;

class Positioned extends Component {
	@:attribute final getTarget:() -> Dynamic;
	@:attribute final attachment:PositionedAttachment;
	@:attribute final gap:Int = 0;
	@:children @:attribute final child:Child;

	function render() {
		#if (js && !nodejs)
		return child.onMount(setup);
		#else
		return child;
		#end
	}

	#if (js && !nodejs)
	function setup() {
		var window = js.Browser.window;
		var el = getPrimitive().as(js.html.Element);

		// @todo: this happens too late in the process and will
		// cause the element to get mounted without being `fixed` first.
		//
		// We may need to make a more custom component to handle this.
		el.style.position = 'fixed';
		el.style.zIndex = '9000'; // @todo: Figure out a universal zIndex api

		window.addEventListener('resize', positionElement);
		window.addEventListener('scroll', positionElement);

		positionElement();

		addDisposable(() -> {
			window.removeEventListener('resize', positionElement);
			window.removeEventListener('scroll', positionElement);
		});
	}

	function positionElement() {
		var el = getPrimitive().as(js.html.Element);
		var target = getTarget().as(js.html.Element);
		var targetRect = target.getBoundingClientRect();
		var container = getContainerSize();
		var vAttachment = attachment.v;
		var hAttachment = attachment.h;

		var top = switch vAttachment {
			case Top:
				(targetRect.top) - el.offsetHeight;
			case Bottom:
				targetRect.bottom;
			case Middle:
				(targetRect.top)
					+ (target.offsetHeight / 2)
					- (el.offsetHeight / 2);
		}
		var left = switch hAttachment {
			case Right:
				targetRect.right;
			case Left:
				targetRect.left - el.offsetWidth;
			case MatchLeft:
				targetRect.left;
			case MatchRight:
				targetRect.right - el.offsetWidth;
			case Middle:
				targetRect.left
				+ (target.offsetWidth / 2)
				- (el.offsetWidth / 2);
		}

		if (overflowsVertical(top, el.offsetHeight)) top = switch vAttachment {
			case Top if (top > 0):
				container.bottom - el.offsetHeight;
			case Top:
				0;
			case Bottom if (top > 0):
				targetRect.top - el.offsetHeight;
			case Bottom:
				0;
			case Middle if (top > 0):
				targetRect.top;
			case Middle:
				0;
		}

		if (overflowsHorizontal(left, el.offsetWidth)) {
			left = switch hAttachment {
				case Right | MatchRight:
					targetRect.right - el.offsetWidth;
				case Left | MatchLeft:
					0;
				case Middle if (left > 0):
					targetRect.right - el.offsetWidth;
				case Middle:
					0;
			}
		}

		if (gap > 0) switch attachment {
			case {v: Top, h: _}:
				top = top - gap;
			case {v: Bottom, h: _}:
				top = top + gap;
			case {v: Middle, h: Middle}:
				left + gap;
			default:
		}

		el.style.top = '${top}px';
		el.style.left = '${left}px';
	}
	#end
}

#if (js && !nodejs)
private function getContainerSize():{
	top:Float,
	bottom:Float,
	left:Float,
	right:Float
} {
	return {
		left: 0,
		top: 0,
		bottom: js.Browser.window.outerHeight,
		right: js.Browser.window.outerWidth
	};
}

private function overflowsVertical(top:Float, height:Float) {
	return top < 0 || top + height >= getContainerSize().bottom;
}

private function overflowsHorizontal(left:Float, width:Float) {
	return left < 0 || left + width >= getContainerSize().right;
}
#end
