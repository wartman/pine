package pine.element;

import pine.adapter.Adapter;

interface Root {
  public function requestRebuild(element:Element):Void;
  public function getRootObject():Dynamic;
  public function getAdapter():Adapter;
}
