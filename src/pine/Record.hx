package pine;

import pine.core.Disposable;

/**
  Records can be used to create reactive stores for an
  app's state. They have a similar API to `AutoComponent`.

  Use Records (alongside Providers) when you need to have 
  state outside of a single component.
**/
@:autoBuild(pine.RecordBuilder.build())
interface Record extends Disposable {}
