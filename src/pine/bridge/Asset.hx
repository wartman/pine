package pine.bridge;

using Kit;

interface Asset {
  public function getIdentifier():Null<String>;
  public function process(context:AssetContext):Task<Nothing>;
}
