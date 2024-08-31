package pine.component;

function withKeyboardInputHandler(child:Child, handler:(key:KeyType, getModifierState:(modifier:KeyModifier) -> Bool) -> Void, ?options:{preventDefault:Bool}) {
	return KeyboardInput.build({
		child: child,
		handler: handler,
		preventDefault: options?.preventDefault ?? true
	});
}
