package pine.internal;

macro function warn(e) {
  if (haxe.macro.Compiler.getConfiguration().debug) {
    // @todo: Come up with a better idea
    return macro trace($e);
  }
  return macro null;
}
