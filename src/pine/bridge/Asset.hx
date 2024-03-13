package pine.bridge;

using Kit;

interface Asset {
  public function getIdentifier():Null<String>;
  public function process(context:AppContext):Task<Nothing>;
}
