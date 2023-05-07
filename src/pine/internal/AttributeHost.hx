package pine.internal;

@:autoBuild(pine.macro.AttributeBuilder.build())
interface AttributeHost {
  private function getAttributes():Map<String, pine.signal.Signal.ReadonlySignal<Any>>;
}
