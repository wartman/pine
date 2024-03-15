package site.data;

enum abstract MenuOptionType(String) {
  final PageLink;
  final ExternalLink;
}

class MenuOption extends Model {
  @:constant public final label:String;
  @:constant public final type:MenuOptionType;
  @:constant public final url:String;
}
