package pine.hook;

interface Hook {
  public function createHookState(context:Context):HookState<Dynamic>;
}
