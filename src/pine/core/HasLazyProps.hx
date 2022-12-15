package pine.core;

/**
  Allows a class to use `@:lazy` props. These properties will be
  initialized the first time they're used instead of immediately
  in the constructor. This can be useful to ensure null safety.
**/
@:remove
@:autoBuild(pine.core.HasLazyPropsBuilder.build())
interface HasLazyProps {}
