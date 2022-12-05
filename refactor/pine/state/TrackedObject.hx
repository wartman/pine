package pine.state;

// @todo: This is flawed: because it's doing the @:genericBuild
// thing, it CAN'T use generic params from a class scope. We need 
// to fix that.
@:genericBuild(pine.internal.TrackedObjectBuilder.buildGeneric())
class TrackedObject<T> {}
