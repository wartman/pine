package pine.bridge.internal;

import haxe.macro.Context;

function isServerTarget() {
  return !Context.defined('pine.client');
}

function isClientTarget() {
  return Context.defined('pine.client');
}
