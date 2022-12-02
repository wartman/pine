package pine;

import pine.core.Disposable;

/**
  Records can be used to create reactive stores for an
  app's state. They have a similar API to `AutoComponent`, allowing you
  to define immutable `@prop` and trackable `@track` properties.

  Use Records (alongside Providers) when you need to have 
  state outside of a single component.
**/
@:autoBuild(pine.internal.RecordBuilder.build())
interface Record extends Disposable {}
